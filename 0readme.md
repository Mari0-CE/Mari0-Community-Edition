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



planned features for next commit: 2x2 tile as a settable property, more things to do with integers (such as using them in numinput for animations), more things with animated tiles (such as them triggering directly on global booleans), an example mappack