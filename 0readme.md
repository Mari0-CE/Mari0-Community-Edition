Various changes to graphics

"givesacoin" and "givescoinamount" for custom enemies, behaving kind of like givesalife but just for an amount of coins

"givestime" and "givestimeamount" for custom enemies, behaving similarly to givesacoin but for time (music may become jank, but whatever)

global booleans! can be read by entities and outputted to by collecting customenemies with "booloncollect", as well as read and written by animations.

	usage of "booloncollect": booloncollect should be a 	string with the name of your boolean, and 	"boolactoncollect" should be one of {"true", "false", 	"flip"}, depending on what you want the output to be. 	Useful for red coins and stuff like that. The integer 	equivalent will be added when global integers are 	debroken.

global integers! can be used in almost any way global booleans can, but for now are broken and shouldn't be.