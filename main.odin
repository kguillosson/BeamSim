package main

import rl "vendor:raylib"
import "core:time"
import "core:fmt"
import "core:math"


nb_sources :int: 32
max :f32 = f32(nb_sources)

displayControlSlider :: proc(phi :f32, width, height:i32){
	rl.DrawRectangleLines(0, 0, width, height, rl.WHITE) //draw the outline of the bar
	rl.DrawRectangle(0, 0, i32((phi/(math.PI)+0.5)*f32(width)), height, rl.GRAY)


}

drawSources :: proc(source_pos : [nb_sources]rl.Vector2){
	for pos in source_pos{
		rl.DrawCircleV(pos, 2, rl.GREEN)
	}
}

f32abs2u8 :: proc(input:f32, max:f32)->u8{
	tmp:f32 = abs(input)/max
	out:u8 = u8(tmp*tmp*255)
	return out
}

main :: proc(){

	//init variables
		//screen size
	window_height :i32= 600
	window_width :i32 = 600

		//source placement params
	wavelength :f32= 8 //in px, which coresp to a pixel at this time
	inter_source_dist :f32= 0.5 //relative to the wavelength
	margin :f32= 32 // in px, distance between the sources and the left border of the screen

		//setting up the array representing the sources positions
	array_length :f32= wavelength*inter_source_dist*f32(nb_sources)
	assert(array_length<f32(window_height), "can't put all the sources in screen size")
	offset :rl.Vector2= {0, wavelength*inter_source_dist}
	source_pos :[nb_sources]rl.Vector2
	source_pos[0] = {margin, f32(window_height/2)-array_length/2}

	for i:int=1; i<nb_sources; i+=1{
		source_pos[i] = source_pos[i-1]+offset
	}

		//generic utils
	change : bool = true
	interacting_with_slider :bool= false
	slider_width :i32=200
	slider_width_f32 :f32= f32(slider_width)
	slider_height :i32=30
	slider_height_f32 :f32= f32(slider_height)
		//wave parameters, those will eventually be modifiable
	phi :f32=math.PI/4 // \in [-PI/2;PI/2[
	//init window
	rl.InitWindow(window_width, window_height, "BeamSim")

		// init the image used to show the waves
	wave_image :rl.Image= rl.GenImageColor(window_width, window_height, rl.BLACK)
	
		//init the texture we will display
	wave_texture :rl.Texture2D=rl.LoadTextureFromImage(wave_image) 


	for !rl.WindowShouldClose(){
		//logic
		if change{//there was a change of params since last frame, or this is the first frame
			start :time.Tick = time.tick_now()
			//compute the waves on wave_image
			for y :i32=0; y<window_height; y+=1{
				for x :i32=0; x<window_width; x+=1{
					current_pos :rl.Vector2= {f32(x), f32(y)}
					val :f32= 0
					dist :f32= 0
					for pos, idx in source_pos{
						dist = rl.Vector2Distance(current_pos, pos)
						val += math.sin_f32(dist/wavelength*math.PI+phi*f32(idx))
					}
					val_abs_u8 :u8= f32abs2u8(val, max)

					color:rl.Color
					if val>0{
						color ={val_abs_u8,0,0,255} 
					}else{
						color ={0,0,val_abs_u8,255} 
					}
					//fmt.println(color)
					rl.ImageDrawPixel(&wave_image, x, y, color)
					
 				}
			}

			//convert the image to a texture for display
			pixels :[^]rl.Color= rl.LoadImageColors(wave_image)
			rl.UpdateTexture(wave_texture, pixels)
			rl.UnloadImageColors(pixels)
			change=false
			fmt.println("computing beam took: ", time.tick_since(start))

		}
		//lets put some control over phi the phase shift
		if rl.IsMouseButtonPressed(.LEFT) && rl.CheckCollisionPointRec(rl.GetMousePosition(), {0,0, slider_width_f32, slider_height_f32}){
			interacting_with_slider = true
		}
		if interacting_with_slider{
			mouse_pos :rl.Vector2= rl.GetMousePosition()
			phi = min(math.PI, mouse_pos.x/slider_width_f32*math.PI)-math.PI/2
		}
		if rl.IsMouseButtonReleased(.LEFT){
			interacting_with_slider = false
			change = true
			fmt.println("phi =",phi)
		}
		//display
		rl.BeginDrawing()
		rl.DrawTexture(wave_texture, 0, 0, rl.WHITE)
		drawSources(source_pos)
		displayControlSlider(phi, slider_width, slider_height)
		//displaying the control slider for phi

		rl.EndDrawing()
	}
	rl.UnloadTexture(wave_texture)
	rl.UnloadImage(wave_image)
	

	
}