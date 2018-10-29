Various changes to graphics

"givesacoin" and "givescoinamount" for custom enemies, behaving kind of like givesalife but just for an amount of coins

"givestime" and "givestimeamount" for custom enemies, behaving similarly to givesacoin but for time (music may become jank, but whatever)

global booleans! can be read by entities and outputted to by collecting customenemies with "booloncollect", as well as read and written by animations.

	usage of "booloncollect": booloncollect should be a string with the name of your boolean, and "boolactoncollect" should be one of {"true", "false", "flip"}, depending on what you want the output to be. Useful for animations. 

global integers! can be used in almost any way global booleans can, ~but for now are broken and shouldn't be.~

global integers hopefully work now?

added intoncollect: 
	:intoncollect" should be a string with the name of your integer, "intactoncollect" should be one of {"add", "subtract", "set"}, and "intactvalue" should be a number, depending on what you want the output to be. Useful for red coins and stuff like that. 

added outputting on transform:
	"transfoutid" is the string with the name of your boolean/integer, "transfoutaction" is the action which is performed on the boolean/integer (any which is defined above), "transfoutvalue" should be an integer if you're outputting to an integer and false if you're outputting to a boolean, and "dontactuallytransform" can be set to true if you don't want the enemy to actually transform. there is no "outputsontransform" - transfoutid and transfoutaction serve that purpose. 

added playsound for animations.

added a couple sounds. 



planned features for next commit; more things to do with integers (such as using them in numinput for animations), more things with animated tiles (such as them triggering directly on global booleans), an example mappack

new random thing: animations now accept names of globints as numinput. it can also take a built-in variable such as marioworld or mariocoincount with the input "g:marioworld" or "g:mariocoincount". I think. 
I may also add this to globinttrigger entities.

tile property #19 (next to foreground): 2x2.

fix: the lowtime sound can now only play once, usually.

...If anything about this is broken, help me fix it, please.



realised that global integers (or glints as they will now be referred to as) can store text, so officially supported that and may add more functions for it

dialog boxes and textentities can now print globools, glints, and even built-in variables using the prefixes "gb:" "gi:" or "bi:"

also added the prefix "bb:" for a human-readable version of a globool... could not isolate crash on trying to update a textentity though

random fix: the intro now actually says CE for more than one frame

integrated turretbot's MultiCustomTiles mod unsuccessfully - help me successfully integrate it and also add a dropdown for selecting between tilesets http://forum.stabyourself.net/viewtopic.php?f=13&t=4649

updated title image - do you like it? If you don't, you don't need to include it



added behaviour "directfromblock" to make a custom enemy not do an itemanimation

also added "collectsound" which does exactly what it says on the tin

implemented D-prog-55:sound-stuff, successfully this time

finished raccoon character

unadded sounds

will make trueflyhorizontal/trueflyvertical that actually travels using speedx