
breed [mosquitoes mosquito]
breed [people person]
breed [doctors doctor ]

mosquitoes-own [ gender immunity ]

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  reset-ticks               ;; clear all patches and turtles
  
  set-default-shape people "person"
    create-people 35 [
    set color blue
    if who < initial-sick-people [set color red] ; these people start off with malaria
      set size 1.5  ;; easier to see
    setxy random-xcor random-ycor ;they are spread out randomly
    ifelse bed-nets ; if people use bed nets the people without malaria will be yellow and can not be bitten by a mosquito
            [ask people [if who >= initial-sick-people [set color yellow] ] ]
            [ask people [if who >= initial-sick-people [set color blue] ] ]

  ]
  set-default-shape mosquitoes "mosquito"  ;; shape is defined in Turtle Shapes Editor
   create-mosquitoes initial-number-mosquitoes ;; create the mosquitoes, then initialize their variables
  [
    set color green
    set size 0.75  ;; easier to see
    setxy random-xcor random-ycor
  ]
   create-mosquitoes 1
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
        [if any? mosquitoes with [color = green]
                      [set color red]
        ]
      ]

      [ask mosquitoes in-radius bite-likelihood ; if people are not infectious they can be infected by infectious mosquitoes in relation to the bite-likelihood
        [ifelse color = red ;if mosquitoes are infectious they can infect nearby non-infected people
                      [ask people in-radius bite-likelihood [if any? people in-radius bite-likelihood with [color = blue]
                                                                              [set color red] ]]
                      [ask people in-radius bite-likelihood with [color = blue] [if any? people in-radius bite-likelihood with [color = blue]
                                                                              [set color blue]] ;if noninfectious mosquitoes bite noninfectious people, nothing happens

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
                                                                        [set color blue]] ]]]]

        [ask doctors in-radius .5 [if any? people in-radius .5 with [color = red] ;if the switch is off there are no doctors so this will not happen
                                                                  [ask people  in-radius .5
                                                                  [set color blue] ]] ]



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
