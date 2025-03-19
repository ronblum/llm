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
      helpText("Type of venue in which the musical was performed"),
      hr()
    ),
    
    mainPanel(
      chat_ui("chat", height = "500px", width = "100%"),
      helpText("Describe the musical that you're interested in."),
    )
  )
)

server <- function(input, output, session) {
  chat <- chat_openai(
    model = "gpt-4o",
    system_prompt = paste("Find only ", stage_type, "musicals. Exclude any that were never performed on ", stage_type, ". ",
                          "Extract the musical most relevant to the topic, the one that's least relevant--but still relevant--to the topic, and one that has nothing to do with the topic (relevancy score of 0). ",
                          "Also capture when and where the musical was first performed. ",
                          "Only return a one or two-line description, and percentage relevance as the score. ",
                          "Display each musical in four lines. ",
                          "On line one, show the name in bold and italics, and without quotes. Then show the year and location in parenstheses and plain text. Then a line break. ",
                          "On line two, show relevancy description in bold and and the relvancy score in bold. Then a line break. ",
                          "On line three, show the description in plain text. ",
                          "On line four, show the year the musical was first performed in parentheses. ",
                          "Only show the field values (e.g. most relevant), not the field types (e.g. recency score)."
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
