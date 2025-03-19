library(dotenv) # Will read OPENAI_API_KEY from .env file
library(ellmer)
library(shiny)
library(shinychat)

musical_schema <- type_object(
  "The muusicals' names, descriptions, relevancy to the topic, and the relevancy score.",
  musical = type_array(
    items = type_object(
      name = type_string("The name of the musical."),
      description = type_string("The description of the musical."),
      relevancy = type_string("The description relevancy of the musical."),
      score = type_string("The relevancy score of the musical.")
    )
  )
)

ui <- bslib::page_fluid(
    sidebarLayout(

    sidebarPanel(
      stage_type <- selectInput("stage_type_input", "Venue Type", 
                  choices = c("Broadway", "Off-Broadway", "Off-Off-Broadway")),
      hr(),
      helpText("Type of stage on which the musical was performed")
    ),
    
    mainPanel(
      chat_ui("chat", height = "500px", width = "100%")
    )
  )
)

server <- function(input, output, session) {
  chat <- chat_openai(
    model = "gpt-4o",
    system_prompt = paste("Find ", stage_type,
                          " musicals that include return the one mmost relevant related to the topic, the one that's least relevant to the topic, and one that has nothing to do with the topc (relevancy score of 0). Only return a one or two-line description and percentage relevance. Display each musical in three liness: 1. Name on line one in bold and italics and no quotes; 2. on the next two, relevancy description in bold and and relvancy score in bold; and 3. on the line three, the description in plain text. Only includes the values, not the fields names."
                          ),
  )
  
  # Function to get structured response
  get_structured_response <- function(prompt) {
    chat$extract_data(
      prompt,
      musicals = musical_schema
    )
  }

  observeEvent(input$chat_user_input, {
    stream <- chat$stream_async(input$chat_user_input)
    chat_append("chat", stream)
  })
}

shinyApp(ui, server)
