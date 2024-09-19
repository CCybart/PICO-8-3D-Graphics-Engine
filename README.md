# PICO-8 3D Graphics Engine
Here is all the code for the test scene for my 3D graphics engine written in PICO-8, as well as the 3D modeling program I wrote for it.

This code isn't able to be run except in PICO-8, and is only here for show. This project was the product of around 2 years of work on and off, and unfortunately I don't have much to show for it. There is a single demo game I made in a day on my PICO-8 Blog linked below.

A large amount of that time and effort was spent optimizing the code, as PICO-8 has severe memory and RAM limitations. I'm very proud of the state that it reached, and there is almost nothing I can do at this point to make the code more efficient without sacrificing some other aspect of its design that I deemed necessary for the purposes I needed it for.

Although I started work on a large game that used this, I became too busy with school work to continue it and have since moved onto other projects.

I learned a lot making this, but most of all I learned (through not succeeding at first) how to not become burnt out on projects and manage goals effectively.

Here is a link to my PICO-8 Blog with other projects, as well as a short demo of the 3D engine I made: https://www.lexaloffle.com/bbs/?uid=51350

# Logistical Info
This is true 3D graphics rasterization, not raycasting. I spent the first couple months or so on this project doing in-depth research on the inner workings of 3D graphics, and how they got their start. 

The engine can render around 500 polygons of various size, rotation, and hidden-ness per second. This is around the maximum possible according to other PICO-8 developers who have made their own 3D graphics engines, including a software and game developer who had experience working on 3D computer graphics at their advent, Frederic Souchu. Once I met this goal and all the other features were added that I desired, I called it finished, despite it needing a ton of work to turn it from graphics engine to game engine.

Inspired by the way PICO-8 itself is built around limitations, I decided that rather than bake the bytes for the model data into PICO-8's memory, I would store it in its graphics memory as pixels. This would make 3D modeling a fun challenge, as I could only use 15 points per model, and each point could only exist in a 15x15x15 area. Additionally, this would save space for additional code, which is also one of PICO-8's most restricting limitations.

Each model is encoded into 8 columns (which fit neatly on PICO-8's 8x8 sprites, at least horizontally). PICO-8 has only 16 colors (15 excluding black) which are numbered from 0-15. This means that each pixel is a number, and since all 3D data is just numbers, this meant for a fairly straightforward conversion. Columns 1-3 are the x, y, and z coordinates for each point, where each row of these 3 columns is a point. Each point from the first 3 columns is stored in a list when the model's sprite is read. Columns 5-8 are made up of the indices of the points from the list that make up each triangle (or quadtrilateral), where each row of these 3-4 columns is a polygon. Column 4 is the color that that each corresponding row's polygon should have when rendered.

Because the size of the models is so small, I also created support to "arrange" different model sprites (with transformation, scaling, and rotation) and combine them into one model in the game's memory.

Other than this rather complicated way of storing model data, all of the computation for rasterization is standard.

Since a z-buffer is too expensive to calculate on a pixel by pixel basis, depth-sorting of each polygon is used instead, where the depth of each polygon is estimated.

Distance, frustum, and back-face culling are all used and the cases for each are calculated efficiently.

Frustum culling was especially difficult to implement, as it requires that when a polygon intersect with the camera's view plane, that polygon must be discarded and new polygons must be created at runtime that split up the original polygon in a way that does not go behind the camera, as doing so would result in the polygon not being rendered at all (due to a division by zero)

All the code is mine except the code used to fill triangles, as years were spent by other PICO-8 developers to find the fastest and most accurate solution.
