LoadPlugin("\VSFilter.DLL")
#Loade VSFilter
LoadPlugin("E:\Bilibili\Tools\小丸工具箱七七版rev117\tools\avsfilter\LSMASHSource.dll")
#Load LSMASHSource
V_str = "20151004 Hot Hot Bacon Dogs by the BBQ Pit Boys-RNQseNiEDN4.mp4"
V = LWLibavVideoSource(V_str, stream_index = -1, threads = 0, 
\                  cache = true, seek_mode = 0, seek_threshold = 10, dr = false, 
\                  fpsnum = 0, fpsden = 1, repeat = false, dominance = 0, stacked = false, format = "")
#Video Source
A = LWLibavAudioSource(source = V_str, stream_index = -1, cache = true, av_sync = false, layout = "", rate = 0)
#Audioo Source

function Pic_Subtitle(clip source_video, string picture_filename, int left, int top, int frame_start, int frame_end)
{
	#source_video, picture_filename, left image position X, top image position Y, frame_start video frame start, frame_end video frame end
	picture = ImageSource(picture_filename, pixel_type = "RGB32")
	video_middle = Overlay(source_video, picture, mask = picture.ShowAlpha(), left, top).Trim(frame_start, frame_end)
	#Combine video and image
	video_result = source_video.Trim(0, frame_start -1) + video_middle + source_video.Trim(frame_end + 1, 0)
	#Get the full video
	return video_result
}

function Vid_Subtitle(clip source_video, string alpha_video, int frame_start, int frame_end)
{
	#source_video, alpha_video, left image position X, top image position Y, frame_start video frame start, frame_end video frame end
	#video = DirectShowSource(alpha_video)
	video = LWLibavVideoSource(alpha_video, stream_index = -1, threads = 0, 
	\                  cache = true, seek_mode = 0, seek_threshold = 10, dr = false, 
	\                  fpsnum = 0, fpsden = 1, repeat = false, dominance = 0, stacked = false, format = "")
	video_middle = Overlay(source_video.Trim(frame_start, frame_end), video, mask = ShowAlpha(video), mode = "blend", opacity = 1)
	#Combine alpha video and original video
	video_result = source_video.Trim(0, frame_start -1) + video_middle + source_video.Trim(frame_end + 1, 0)
	#Get the full video
	return video_result
}

function PicAnime_Subtitle(clip source_video, string picture_sequence, int sequence_start, int sequence_end, int frame_start, int frame_end, float input_fps)
{
	#source_video, picture_sequence, sequence start number, sequence end number, video frame start, video frame stop, video frame per second
	#video = DirectShowSource(alpha_video)
	video = ImageReader(file = picture_sequence, start = sequence_start, end = sequence_end, fps = input_fps, use_DevIL = false, info = false, pixel_type = "RGB32")
	video_middle = Overlay(source_video.Trim(frame_start,frame_end), video, mask=ShowAlpha(video), mode="blend", opacity=1)
	#Combine video and image
	v_result = frame_start == 0 ? Eval("""	
		video_result = video_middle + source_video.Trim(frame_end + 1,0)
		#Process form start
		return video_result	
	""") : Eval("""
		video_result = source_video.Trim(0,frame_start -1) + video_middle + source_video.Trim(frame_end + 1,0)
		#Process from middle
		return video_result
	""")
	return v_result
}


V = Pic_Subtitle(V, "image_with_alpha_channel.png", 0, 0, 2277, 2320)
V = Vid_Subtitle(V, "video_with_alpha_channel.avi", 0, 0, 11682, 11773)
V = PicAnime_Subtitle(V, ".\image_sequence\image_sequence_with_alpha_channel_%05d.png", 42, 91, 8628, 8677, 29.97)
AudioDub(V, A)

TextSub("The subtitle you need.ass")

ConvertToYV12()
