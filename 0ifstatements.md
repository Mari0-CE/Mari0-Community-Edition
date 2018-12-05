plans:

if statements:
[delay, [greaterThan, var, arg], [[action1, arg],[action2, arg]] ]
[delay, [lessThan, var, arg], [[action1, arg],[action2, arg]] ]
[delay, [equalThan, var, arg], [[action1, arg],[action2, arg]] ]
[delay, [isTrue, var], [[action1, arg],[action2, arg]] ]

[simultaneous, [action1, arg], [action2, arg], ...]

complex args:

[global, cArg] 
[self, cArg]
[concat, arg1, arg2]