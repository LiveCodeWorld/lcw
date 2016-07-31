script "Global_Movie_Capture_Menu"
--> MetaData
-
license: GPLv3
name: Global_Movie_Capture_Menu
type: controller
version: 0.1

local LocalArray


--> Global | Movie | Capture | Menu
-
on menu_StartCapture
   revCaptureBeginSession
   put it into someIt
   put the result into someResult
   put true into LocalArray ["revCaptureBeginSession"]
end menu_StartCapture

on _
end _

on menu_AudioInput imageView, audioInput
   revCaptureSetAudioInput audioInput
end menu_AudioInput

on menu_VideoInput imageView, videoInput
   revCaptureSetVideoInput videoInput
end menu_VideoInput

on menu_AudioCodec imageView, audioCodec
   revCaptureSetAudioCodec audioCodec
end menu_AudioCodec

on menu_VideoCodec imageView, videoCodec
   revCaptureSetVideoCodec videoCodec
end menu_VideoCodec

on _
end _

on menu_StopCapture
   put false into LocalArray ["revCaptureBeginSession"]
   revCaptureEndSession
end menu_StopCapture


--> Global | Movie | Capture | Menu | Props
-
getprop audio_Codec
   return revCaptureGetAudioCodec()
end audio_Codec
   
getprop audio_Codecs
   return revCaptureListAudioCodecs()
end audio_Codecs
   
getprop video_Codec
   return revCaptureGetVideoCodec()
end video_Codec
   
getprop video_Codecs
   return revCaptureListVideoCodecs()
end video_Codecs
   
getprop audio_Input [imageView]
   return revCaptureGetAudioInput()
end audio_Input

getprop audio_Inputs [imageView]
   put revCaptureListAudioInputs() into audioInputs
   if audioInputs is empty then
      return "default,none"
   else
      put "default,none,-" & CR before audioInputs
      return audioInputs
   end if
end audio_Inputs

getprop video_Input [imageView]
   return revCaptureGetVideoInput()
end video_Input

getprop video_Inputs [imageView]
   put revCaptureListVideoInputs() into videoInputs
   if videoInputs is empty then
      return "default,none"
   else
      put "default,none,-" & CR before videoInputs
      return videoInputs
   end if
end video_Inputs


--> Global | Movie | Capture | Menu | Disabled
-
getprop disabled_StartCapture
   return LocalArray ["revCaptureBeginSession"] is true
end disabled_StartCapture

getprop disabled_AudioInput
   return LocalArray ["revCaptureBeginSession"] is not true
end disabled_AudioInput

getprop disabled_VideoInput
   return LocalArray ["revCaptureBeginSession"] is not true
end disabled_VideoInput

getprop disabled_StopCapture
   return LocalArray ["revCaptureBeginSession"] is not true
end disabled_StopCapture


--> Menu | Props
-
