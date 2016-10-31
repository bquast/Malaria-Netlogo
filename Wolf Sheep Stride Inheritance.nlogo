globals [
  max-energy           ;; the maximum amount of energy any animal can have
  min-energy           ;; the minimum amount of energy an animal needs to reproduce
  max-stride           ;; the maximum stride length, the minimum stride length is 0,
                       ;; the stride will always be between these limits
  mosquito-gain-from-food  ;; energy units mosquitoes get for eating
  cows-gain-from-food ;; energy units cows get for eating
  cows-reproduce      ;; probability that cows will reproduce at each time step
  mosquito-reproduce       ;; probability that mosquitoes will reproduce at each time step
  grass-regrowth-time  ;; number of ticks before eaten grass regrows.
  bite-likelihood      ;; likelihood of biting when in radius
  initial-cows-stride
  initial-mosquito-stride
]

breed [cows cow]
breed [mosquitoes mosquito]

turtles-own [ energy stride-length ]
mosquitoes-own [ male ]
patches-own [ countdown ]  ;; patches countdown until they regrow

to setup
  clear-all
  ;; initialize constant values
  set max-stride 3
  set min-energy 200
  set max-energy 500
  set mosquito-gain-from-food 50
  set cows-gain-from-food 8
  set cows-reproduce 1
  set mosquito-reproduce 50
  set grass-regrowth-time 80
  set bite-likelihood 0.5
  set initial-cows-stride 0.2
  set initial-mosquito-stride 0.2

  ;; setup the grass
  ask patches [ set pcolor green ]
  ask patches [
    set countdown random grass-regrowth-time ;; initialize grass grow clocks randomly
    if random 2 = 0  ;;half the patches start out with grass
      [ set pcolor brown ]
  ]

  set-default-shape cows "cow"
  create-cows initial-clean-cows  ;; create the cows, then initialize their variables
  [
    set color white
    set stride-length initial-cows-stride
    set size max-stride  ;; easier to see
    set energy random max-energy
    setxy random-xcor random-ycor
  ]
  create-cows initial-infected-cows
  [
    set color red
    set stride-length initial-cows-stride
    set size max-stride  ;; easier to see
    set energy random max-energy
    setxy random-xcor random-ycor
  ]

  set-default-shape mosquitoes "mosquito"
  create-mosquitoes initial-clean-mosquitoes  ;; create the mosquitoes, then initialize their variables
  [
    set male true
    set color blue
    if random 2 = 0 ;; make half the mosquitoes female
    [
      set male false
      set color pink
    ]
    set stride-length initial-mosquito-stride
    set size max-stride  ;; easier to see
    set energy random max-energy
    setxy random-xcor random-ycor
  ]
  reset-ticks
end

to go
  if not any? turtles [ stop ]
  ask cows [
    move
    ;; cows always loose 0.5 units of energy each tick
    set energy energy - 0.5
    ;; if larger strides use more energy
    ;; also deduct the energy for the distance moved
    ;; if stride-length-penalty?
    ;; [ set energy energy - stride-length ]
    ifelse color = red ;if cows are infectious they will infect mosquitoes who bite them in relation to the bite-likelihood
      [ask mosquitoes in-radius bite-likelihood
        [eat-blood
         if any? mosquitoes with [color = pink]
                      [set color red]
        ]
      ]
      [ask mosquitoes in-radius bite-likelihood ; if cows are not infectious they can be infected by infectious mosquitoes in relation to the bite-likelihood
        [eat-blood
         ifelse color = red ;if mosquitoes are infectious they can infect nearby non-infected cows
                      [ask cows in-radius bite-likelihood [if any? cows in-radius bite-likelihood with [color = white]
                                                                              [set color red] ]]
                      [ask cows in-radius bite-likelihood with [color = white] [if any? cows in-radius bite-likelihood with [color = white]
                                                                              [set color white]] ;if noninfectious mosquitoes bite noninfectious cows, nothing happens

       ]
      ]
      ]
    eat-grass
    maybe-die
    reproduce-cows
  ]
  ask mosquitoes [
    move
    ;; mosquitoes always loose 0.5 units of energy each tick
    set energy energy - 0.5
    ;; if larger strides use more energy
    ;; also deduct the energy for the distance moved
    ;; if stride-length-penalty?
    ;; [ set energy energy - stride-length ]
    ;; catch-cows
    maybe-die
    reproduce-mosquitoes
  ]
  ask patches [ grow-grass ]
  tick
end

to move  ;; turtle procedure
  rt random-float 50
  lt random-float 50
  fd stride-length
end

to eat-grass  ;; cows procedure
  ;; cows eat grass, turn the patch brown
  if pcolor = green [
    set pcolor brown
    set energy energy + cows-gain-from-food  ;; cows gain energy by eating
    if energy > max-energy
    [ set energy max-energy ]
  ]
end

to eat-blood ;; mosquito procedure
    set energy energy + mosquito-gain-from-food
    if energy > max-energy
    [ set energy max-energy ]
end

to reproduce-cows  ;; cows procedure
  ;; reproduce cows-reproduce cows-stride-length-drift white
    if random-float 100 < cows-reproduce and energy > min-energy [
    set energy (energy / 2 )  ;; divide energy between parent and offspring
    hatch 1 [
      rt random-float 360
      fd 1
      ;; mutate the stride length based on the drift for this breed
      ;; set stride-length mutated-stride-length cows-stride-length-drift
      set color white
    ]
    ]
end

to reproduce-mosquitoes  ;; mosquito procedure
  ;; reproduce mosquito-reproduce mosquito-stride-length-drift pink
    if random-float 100 < mosquito-reproduce and energy > min-energy and color = pink [
    set energy (energy / 2 )  ;; divide energy between parent and offspring
    hatch 1 [
      rt random-float 360
      fd 1
      ;; mutate the stride length based on the drift for this breed
      ;; set stride-length mutated-stride-length mosquito-stride-length-drift
      set color pink
      if random-float 2 < 1 [
        set color blue
      ]
    ]
    ]
end

;;to-report mutated-stride-length [drift] ;; turtle reporter
;;  let l stride-length + random-float drift - random-float drift
;;  ;; keep the stride lengths within the accepted bounds
;;  if l < 0
;;  [ report 0 ]
;;  if stride-length > max-stride
;;  [ report max-stride ]
;;  report l
;;end

to maybe-die  ;; turtle procedure
  ;; when energy dips below zero, die
  if energy < 0 [ die ]
end

to grow-grass  ;; patch procedure
  ;; countdown on brown patches, if reach 0, grow some grass
  if pcolor = brown [
    ifelse countdown <= 0
      [ set pcolor green
        set countdown grass-regrowth-time ]
      [ set countdown countdown - 1 ]
  ]
end


; Copyright 2006 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
466
12
1213
734
32
30
11.34
1
20
1
1
1
0
1
1
1
-32
32
-30
30
1
1
1
ticks
30.0

SLIDER
10
204
205
237
initial-clean-cows
initial-clean-cows
0
250
64
1
1
NIL
HORIZONTAL

SLIDER
213
204
456
237
initial-clean-mosquitoes
initial-clean-mosquitoes
0
250
30
1
1
NIL
HORIZONTAL

BUTTON
3
11
211
44
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
215
11
459
44
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
31
587
452
730
populations
time
pop.
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"cows" 1.0 0 -16777216 true "" "plot count cows"
"mosquitoes" 1.0 0 -13345367 true "" "plot count mosquitoes"
"grass / 4" 1.0 0 -10899396 true "" ";; divide by four to keep it within similar\n;; range as wolf and sheep populations\nplot count patches with [ pcolor = green ] / 4"
"inf. cows" 1.0 0 -2674135 true "" "plot count cows with [ color = red ]"

MONITOR
54
324
132
369
cows
count cows
3
1
11

MONITOR
214
323
292
368
mosq.
count mosquitoes
3
1
11

MONITOR
134
324
213
369
inf. cows
count cows with [ color = red ]
0
1
11

SLIDER
9
239
212
272
initial-infected-cows
initial-infected-cows
0
100
2
1
1
NIL
HORIZONTAL

SLIDER
213
238
455
271
initial-infected-mosquitoes
initial-infected-mosquitoes
0
100
0
1
1
NIL
HORIZONTAL

MONITOR
291
323
371
368
inf. mosq.
count mosquitoes with [ color = red ]
17
1
11

MONITOR
54
371
165
416
prop. inf. cows
count cows with [ color = red ] / count cows
4
1
11

MONITOR
214
370
370
415
prop. inf. mosq.
count mosquitoes with [ color = red ] / count mosquitoes
4
1
11

PLOT
32
432
452
582
infection rates
time
inf. rate
0.0
10.0
0.0
0.1
true
false
"" ""
PENS
"cows" 1.0 0 -16777216 true "" "plot count cows with [ color = red ] / count cows"
"mosquitoes" 1.0 0 -2064490 true "" "plot count mosquitoes with [ color = red ] / count mosquitoes"

@#$#@#$#@
## WHAT IS IT?

This model is a variation on the predator-prey ecosystems model wolf-sheep predation.
In this model, predator and prey can inherit a stride length, which describes how far forward they move in each model time step.  When wolves and sheep reproduce, the children inherit the parent's stride length -- though it may be mutated.

## HOW IT WORKS

At initialization wolves have a stride of INITIAL-WOLF-STRIDE and sheep have a stride of INITIAL-SHEEP-STRIDE.  Wolves and sheep wander around the world moving STRIDE-LENGTH in a random direction at each step.  Sheep eat grass and wolves eat sheep, as in the Wolf Sheep Predation model.  When wolves and sheep reproduce, they pass their stride length down to their young. However, there is a chance that the stride length will mutate, becoming slightly larger or smaller than that of its parent.

## HOW TO USE IT

INITIAL-NUMBER-SHEEP: The initial size of sheep population
INITIAL-NUMBER-WOLVES: The initial size of wolf population

Half a unit of energy is deducted from each wolf and sheep at every time step. If STRIDE-LENGTH-PENALTY? is on, additional energy is deducted, scaled to the length of stride the animal takes (e.g., 0.5 stride deducts an additional 0.5 energy units each step).

WOLF-STRIDE-DRIFT and SHEEP-STRIDE-DRIFT:  How much variation an offspring of a wolf or a sheep can have in its stride length compared to its parent.  For example, if set to 0.4, then an offspring might have a stride length up to 0.4 less than the parent or 0.4 more than the parent.

## THINGS TO NOTICE

WOLF STRIDE HISTOGRAM and SHEEP STRIDE HISTOGRAM will show how the population distribution of different animal strides is changing.

In general, sheep get faster over time and wolves get slower or move at the same speed.  Sheep get faster in part, because remaining on a square with no grass is less advantageous than moving to new locations to consume grass that is not eaten.  Sheep typically converge on an average stride length close to 1.  Why do you suppose it is not advantageous for sheep stride length to keep increasing far beyond 1?

If you turn STRIDE-LENGTH-PENALTY? off, sheep will become faster over time, but will not stay close to a stride length of 1.  Instead they will become faster and faster, effectively jumping over multiple patches with each simulation step.

## THINGS TO TRY

Try adjusting the parameters under various settings. How sensitive is the stability of the model to the particular parameters?

Can you find any parameters that generate a stable ecosystem where there are at least two distinct groups of sheep or wolves with different average stride lengths?

## EXTENDING THE MODEL

Add a cone of vision for sheep and wolves that allows them to chase or run away from each other.   Make this an inheritable trait.

## NETLOGO FEATURES

This model uses two breeds of turtle to represent wolves and sheep.

## RELATED MODELS

Wolf Sheep Predation, Bug Hunt Speeds

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Novak, M. and Wilensky, U. (2006).  NetLogo Wolf Sheep Stride Inheritance model.  http://ccl.northwestern.edu/netlogo/models/WolfSheepStrideInheritance.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2006 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2006 Cite: Novak, M. -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

mosquito
false
0
Circle -7500403 true true 75 105 30
Circle -7500403 true true 90 105 30
Circle -7500403 true true 105 120 30
Circle -7500403 true true 120 135 30
Line -7500403 true 105 105 135 15
Line -7500403 true 135 15 165 0
Line -7500403 true 165 0 180 15
Line -7500403 true 180 15 195 45
Line -7500403 true 195 45 195 60
Line -7500403 true 195 60 120 120
Line -7500403 true 105 120 90 150
Line -7500403 true 105 120 90 255
Line -7500403 true 105 135 120 270
Polygon -7500403 true true 90 105 30 165 90 120
Line -7500403 true 105 105 90 15
Line -7500403 true 90 15 60 30
Line -7500403 true 60 30 45 60
Line -7500403 true 45 60 105 120
Circle -7500403 true true 135 150 30

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
setup
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
