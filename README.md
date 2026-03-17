# Book Of the Dead - Unity 6
![PromotionalScreenShot](https://assetstorev1-prd-cdn.unity3d.com/package-screenshot/aa4da373-1944-4836-897d-fe786c28f2b4_scaled.jpg)

Book of the Dead project for Unity6: Updated from Delacrowa's original repository: https://github.com/Delacrowa/book-of-the-dead-environment-hdrp
Special biggup to Delacrowa for hosting this content and posting it to the community, and to Unity Technologies' staff who worked on this awesome demo.

Old demo from 2018 and Assets store were for Unity 2018, but it had bugs and were not "as it" fully usable with the latest Unity version (2022+).
So here is the updated content, with a few minor changes to match Unity's HDRP new capacity.

.Complete original Demo Scene

.Implemented the FFH template

.*FSR2 + realtime GI setup* (recentlky changed)

How to => you can load BOTD gameplay content by loading BootStrapDemo.unity(which have the global volumes for sky etc) in Assets/FarFromHere/..
Then use the SceneLoader gameObject to load the full BOTD ScenesList, press play, and enjoy :)

Lastest Updataes :
. Added Mesh LOD to some mesh 

. Removed FSR2 to use STP + DynaResoltion => try 

. Restored lighting closer to the Original Demo content

. Restored layer culling functionality, and a few other features on the Cinemachine 3 cameras => I added a flying camera using the new Input system by default, but you can, of course, re-enable the original FPS player controller. 

With this update, I can run the 2K-resolution rendering (dynamic resolution On) at an average of 80 FPS with no slowness on a 3060.

# Suggestion: You should really try to test out the Demo, magnifying it with a cinematic resolution like 2850/1000px, this should give a quite insane result on your screen.

![PromotionalScreenShot](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExODVpbHIweXUyaDF5d3M3dmh3dDQ2M2t6Ynl4MDFhMGxvZ2JsM2N5ciZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/gjQayITaYM6K4YvtxH/giphy.gif)


 
Original description :

This package uses the following components under the following licenses (see ThirdPartyNotices.txt file for details):

  - Post-processing, Shader Graph, Render Pipeline Core, High Definition Render Pipeline, Probuilder: Unity Companion License
  - Poly2Tri: BSD 3-clause
  csg.js, KdTree, Cinder, pb_Stl: MIT
  - MkDocs: BSD 2-clause
  - Asap Font: Sil Open Font License (OFL-1.1)
  - Noise: CC0 1.0
  - HapkiLibs: No copyright is claimed, and you may use it for any purpose you like.
  - TerrainEvo 3: All editor and authoring files are licensed under the Mozilla Public License v2.0; All runtime files are licensed under the BSD 3-clause.

    Book of the Dead trailer
    Forum Thread
    Making-of Articles




