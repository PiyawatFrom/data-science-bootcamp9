## sub-function
judge <- function(hu,com){

    if (hu == com){

        return ("draw")

    } else if (hu == "hammer") {

        if (com == "scissors"){
            return ("win")
        } else if (com == "paper"){
            return ("lose")
        }

    } else if (hu == "scissors") {
        if (com == "hammer"){
            return ("lose")
        } else if (com == "paper"){
            return ("win")
        }

    } else if (hu == "paper" ){
        if (com == "scissors"){
            return ("lose")
        } else if (com == "hammer"){
            return ("win")
        }
    }
}


## main function
game <- function() {
    note_text <- "(1) hammer , (2) scissors , (3) paper , (4) stop playing"
    print(note_text)

    ## setting
    hands <- c("hammer","scissors","paper")
    human_score <- 0
    com_score <- 0

    ## Loop
    play_times <- 0

    while (TRUE) {
        flush.console()
        action <- as.numeric(readline("Type 1 2 3 or 4 : "))

        if (action == 4) {

            break

        } else if (action == 1 |action == 2| action == 3) {

            human_hand <- hands[action]
            com_hand <- sample(hands,1)
            play_times = play_times + 1

            ## rule check

            result <- judge(hu = human_hand, com = com_hand)

            if (result == "win"){

                human_score = human_score + 1

            } else if (result == "lose") {

                com_score = com_score + 1
            }

            print( paste("round",play_times,"com:",com_hand,", your status:",result) )

        } else {
            print("wrong number")
            break
        }
    }

    ## End
    print("------Sumary------")
    print(paste("play times =", play_times , "," ,
                "human score =" , human_score , "," ,
                "computer score =", com_score ))

}

game()
