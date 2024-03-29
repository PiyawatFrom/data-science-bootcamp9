pizza_chatbot <- function() {


    print("Hello This is DD pizza , What do you want to order?")

    menus <- c("Kani Pizza" , "Orion Pizza", "Classic Pep Pizza" , "X pizza")
    prices <- c(220, 350 , 200 ,260)

    print("We have (1)Kani Pizza 220B , (2)Orion Pizza 350B , (3)Classic Pep Pizza 200B  , (4) X pizza 260B")
    flush.console()
    order <- as.numeric(readline("Order ?:"))

    if (order == 1 | order == 2 | order ==3 | order == 4) {
        flush.console()
        por <- as.numeric(readline("How many sets do you want to order? :"))

        od_name <- menus[order]
        total <- por*prices[order]

        sum_text <- paste(od_name,",",por,"sets",", total :",total,"Baht")
        print(sum_text)

        flush.console()

        cus_loc <- readline("what is your location ? :")

        sum_text2 <- paste("OK ,",cus_loc,"right? , It won't take more than 15 minutes to arrive.")
        print(sum_text2)

    } else {
        print("It not funny , don't do again")
    }

}

pizza_chatbot()
