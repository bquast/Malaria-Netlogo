
breed [mosquitoes mosquito]
breed [people person]
breed [doctors doctor ]

mosquitoes-own [ gender immunity ]

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  clear-all
  reset-ticks               ;; clear all patches and turtles


  set-default-shape people "person"
    create-people 35 [
    set color green
    if who < initial-sick-people [set color red] ; these people start off with malaria
      set size 1.5  ;; easier to see
    setxy random-xcor random-ycor ;they are spread out randomly
    ifelse bed-nets ; if people use bed nets the people without malaria will be yellow and can not be bitten by a mosquito
            [ask people [if who >= initial-sick-people [set color yellow] ] ]
            [ask people [if who >= initial-sick-people [set color green] ] ]

  ]
  set-default-shape mosquitoes "mosquito"  ;; shape is defined in Turtle Shapes Editor
   create-mosquitoes initial-number-mosquitoes / 2 ;; create the mosquitoes, then initialize their variables
  [
    set color blue
    set gender "male"
    set size 0.75  ;; easier to see
    setxy random-xcor random-ycor
  ]
   create-mosquitoes initial-number-mosquitoes / 2
  [
    set color pink
    set gender "female"
    set size 0.75  ;; easier to see
    setxy random-xcor random-ycor
  ]
   create-mosquitoes 1 ;; create one immune mosquito
  [
    set immunity true
    set color yellow
    setxy random-xcor random-ycor
  ]

  set-default-shape doctors "doctor"

  ifelse medicine ; if the medicine switch is set to 'on' then 5 randomly placed stationary doctors will be available
    [create-doctors 5  ask doctors [(set size 1.5) (setxy random-xcor random-ycor)]]
    [create-doctors 0]



 end

to go
  move-mosquitoes
  move-people
  do-plots
end




to move-people
  ask people
  [
    rt random 100 ;people move around the world randomly
    lt random 100
    fd 1

    ifelse color = red ;if people are infectious they will infect mosquitoes who bite them in relation to the bite-likelihood
      [ask mosquitoes in-radius bite-likelihood
        [if any? mosquitoes with [color = pink]
                      [set color red]
        ]
      ]

      [ask mosquitoes in-radius bite-likelihood ; if people are not infectious they can be infected by infectious mosquitoes in relation to the bite-likelihood
        [ifelse color = red ;if mosquitoes are infectious they can infect nearby non-infected people
                      [ask people in-radius bite-likelihood [if any? people in-radius bite-likelihood with [color = blue]
                                                                              [set color red] ]]
                      [ask people in-radius bite-likelihood with [color = blue] [if any? people in-radius bite-likelihood with [color = green]
                                                                              [set color green]] ;if noninfectious mosquitoes bite noninfectious people, nothing happens

       ]
      ]
    ]


   ifelse medicine ;if the medicine switch is on
        [ask doctors in-radius .5  [if any? people in-radius .5 with [color = red]
                                                                  [ask people in-radius .5 with [color = red] ;doctors will cure nearby infectious people or people who 'visit' them

                                                                  [ifelse bed-nets ;when bed-nets are used, doctors will cure nearby infectious people and give them a bed-net
                                                                        [ask people in-radius .5 with [color = red]
                                                                        [set color yellow] ]
                                                                        [ask people in-radius .5 with [color = red]
                                                                        [set color green]] ]]]]

        [ask doctors in-radius .5 [if any? people in-radius .5 with [color = red] ;if the switch is off there are no doctors so this will not happen
                                                                  [ask people  in-radius .5
                                                                  [set color green] ]] ]



   ifelse spray-insecticide ;if the insecticide switch is set on
     [ask people
             [set pcolor green - 4] ] ;people will spray patches around them a light green color

      [ask people
             [set pcolor black] ] ;if switch is off the patches will stay black

    ]
      tick
end

to move-mosquitoes
  ask mosquitoes
  [ rt random 100
    lt random 100
    fd 1
  ]

  tick

  ifelse spray-insecticide ; if the insecticide switch is set on
    [ask patches with [pcolor = green - 4]
                             [ask mosquitoes in-radius 1 with [who = random 200] [die]]] ;light green patches that come into contact with mosquitoes will throw out a random number from 1-200, if the number matches the mosquito's who number than it dies
    [if any? mosquitoes with [who = 0]
                             [ask mosquitoes [die]]] ;if the switch is off this will happen...however no mosquito has a who number of 0 so it is impossible to kill mosquitoes unless the switch is set to on



end

to do-plots
  set-current-plot "Totals"
  set-current-plot-pen "people"
  plot count people with [color = red]
end



; *** NetLogo 4.0.2 Model Copyright Notice ***
;
; Copyright 2008 by Erin S. Flanagan.  All rights reserved.
;
; Permission to use, modify or redistribute this model is hereby granted,
; provided that both of the following requirements are followed:
; a) this copyright notice is included.
; b) this model will not be redistributed for profit without permission
;    from Erin S. Flanagan.
; Contact Erin S. Flanagan for appropriate licenses for redistribution for
; profit.
;
; To refer to this model in publications, please use:

; Copyright 2008 Erin S. Flanagan.  All rights reserved.

; This project was funded by NSF and NIH as part of the VCU Bioengineering & Biotechnology Summer Institute.

;
; *** End of NetLogo 4.0.2 Model Copyright Notice ***

; resaved in NetLogo 5.3.1 by Bastiaan Quast on 2016-10-27
@#$#@#$#@
GRAPHICS-WINDOW
383
10
918
416
10
7
25.0
1
10
1
1
1
0
1
1
1
-10
10
-7
7
1
1
1
days
30.0

BUTTON
24
10
89
58
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
145
10
212
57
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
19
66
216
99
initial-number-mosquitoes
initial-number-mosquitoes
0
100
44
1
1
NIL
HORIZONTAL

SLIDER
19
110
217
143
initial-sick-people
initial-sick-people
0
25
4
1
1
NIL
HORIZONTAL

SLIDER
19
150
217
183
bite-likelihood
bite-likelihood
0
1
0.1
.1
1
NIL
HORIZONTAL

SWITCH
225
52
363
85
bed-nets
bed-nets
1
1
-1000

SWITCH
225
95
361
128
medicine
medicine
1
1
-1000

SWITCH
225
10
363
43
spray-insecticide
spray-insecticide
1
1
-1000

MONITOR
223
142
344
187
Number of Sick People
count people with [color = red]
17
1
11

PLOT
19
195
376
415
Totals
days
number of sick people
0.0
365.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""
"people" 1.0 0 -16777216 true "" ""

@#$#@#$#@
## WHAT IS IT?

This model relates the number of people infected with malaria with the use of various control measures such as bed-nets, insecticide, and medicine within a population.  This model was created for elementary students to use and thus the actual transmission rate of the virus has been simplified so that students may interpret the results with no prior knowledge of the disease and limited graphing skills.

## HOW IT WORKS

People contact malaria when bitten by a mosquito carrying the plasmodium parasite.  Infected people bitten by mosquitoes transmit the plasmodium parasite back to the mosquito - propagating the cycle.  This model seeks to demonstrate that relationship as well as the affects of control measures in place to combact the disease.

## HOW TO USE IT

Users choose the initial number of parasite-transmitting mosquitoes to reflect a location as well as the initial number of infected people in the population.  Users also determine a bite-likelihood, which is basically the chance a given person will be in the same space as a mosquito and be bitten.  The graph records the amount of infected people over time within the selected constraints.  Users can also turn on/off three different control measures (or a combination of the three) that will influence the transmission of the disease and affect the amount of sick people in the population.

## THINGS TO NOTICE

This model has several major assumptions:

1. Humans do not reproduce or die.
2. Bed-nets are 100% effective at preventing malaria.
3. Mosquitoes and people interact homogeneously.
4. Cured people (by medicine) cannot get sick again.
5. There is no delay in the mosquito acquiring the parasite and becoming infectious.

These assumptions were necessary to keep the program simple and straightforward, but do affect the accuracy of the results.  However, infection trends and the overall effectiveness of control methods while generalized, does give students a sense of the relationships.

## THINGS TO TRY

Here are three scenarios I used with my own class:

1.A person returns to Anytown, USA from a trip to Africa where he has contacted malaria. Should we people worried? Use the model to demonstrate why or why not. (Students should set initial infected to 1, bite likelihood low, and initial # mosquitoes low).

2.What variables affect the number sick people the most? (Students should test different variables one at a time.  This is great way for students to understand the concept of variables and controls).

3.Malaria in endemic in areas with tropical climates.  Endemic means lots of people have gotten the disease and continue to get the disease today.  Why would people living in tropical areas get malaria more often?  Set up the model so that lots of people get the disease over time.  What do you notice?  (Student should set the model so that the number of initial people infected is high, with a lot of mosquitoes and a high bite-likelihood and little controls in place...this will produce "endemic" results).

## CREDITS AND REFERENCES

This model was created as a project in conjunction with Virginia Commonwealth
Univerity Bioinformatics and Bioengineering Summer Institute.

Copyright 2008 by Erin S. Flanagan.  All rights reserved.

Permission to use, modify or redistribute this model is hereby granted,
a) this copyright notice is included.
b) this model will not be redistributed for profit without permission
from Erin S. Flanagan.
Contact Erin S. Flanagan for appropriate licenses for redistribution for
profit.

To refer to this model in academic publications, please use:

Flanagan, E.S. (2008).  NetLogo Malaria Control model.
Mary Munford Elementary School
Richmond Public Schools, Richmond, VA

In other publications, please use:
Copyright 2008 Erin S. Flanagan.  All rights reserved.
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

boy
false
0
Circle -7500403 true true 107 15 84
Line -7500403 true 150 75 150 224
Line -7500403 true 150 150 74 135
Line -7500403 true 150 149 224 135
Line -7500403 true 150 224 195 284
Line -7500403 true 150 226 105 284

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

doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -6459832 true false 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

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

girl
false
0
Circle -7500403 true true 107 15 84
Line -7500403 true 150 75 150 224
Line -7500403 true 150 150 74 135
Line -7500403 true 150 149 224 135
Line -7500403 true 150 224 195 284
Line -7500403 true 150 226 105 284
Polygon -7500403 true true 150 99 105 267 195 267

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

monster
false
0
Polygon -7500403 true true 75 150 90 195 210 195 225 150 255 120 255 45 180 0 120 0 45 45 45 120
Circle -16777216 true false 165 60 60
Circle -16777216 true false 75 60 60
Polygon -7500403 true true 225 150 285 195 285 285 255 300 255 210 180 165
Polygon -7500403 true true 75 150 15 195 15 285 45 300 45 210 120 165
Polygon -7500403 true true 210 210 225 285 195 285 165 165
Polygon -7500403 true true 90 210 75 285 105 285 135 165
Rectangle -7500403 true true 135 165 165 270

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
setup
repeat 2 [ move-fish ]
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
