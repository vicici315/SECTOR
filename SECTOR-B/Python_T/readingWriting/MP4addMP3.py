import moviepy.editor as mpe
clip = mpe.VideoFileClip("DASH_V.mp4")
audioF = mpe.AudioFileClip("i:/Downloads/Hologram  Scanner - Unreal Engine 4 - DASH_A.mp3")

final_audio = mpe.CompositeAudioClip([audioF, clip.audio])
final_clip = clip.set_audio(final_audio)
final_clip.write_videofile("outVideo.mp4")

