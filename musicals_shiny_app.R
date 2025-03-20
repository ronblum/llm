library(dotenv) # Will read OPENAI_API_KEY from .env file
library(ellmer)
library(shiny)
library(shinychat)

# musical_schema <- type_object(
#   "The muusicals' names, descriptions, relevancy to the topic, first production years, and the relevancy score.",
#   musical = type_array(
#     items = type_object(
#       name = type_string("The name of the musical."),
#       description = type_string("A one- or two-line description of the musical."),
#       relevancy = type_string("The description relevancy of the musical."),
#       score = type_string("The relevancy score of the musical."),
#       year = type_string("The year the musical was first performed.")
#     )
#   )
# )

ui <- bslib::page_fluid(
  sidebarLayout(

    sidebarPanel(
      stage_type <- selectInput("stage_type_input", "Venue Type", 
                  choices = c("Broadway", "Off-Broadway", "Off-Off-Broadway")),
      helpText("Type of venue in which the musical was performed."),
      hr(),
    ),
    
    mainPanel(
      titlePanel("Musical Chatbot", windowTitle = "Musicals Chatbot"),
      chat_ui("chat", height = "500px", width = "100%"),
      helpText("Describe the the kind of musical that you're interested in."),
    ),
    
  )
)

server <- function(input, output, session) {
  chat <- chat_openai(
    model = "gpt-4o",
    system_prompt = paste("Only talk about musicals. ",
                          "Select musicals, but only those that were performed ", stage_type, ". ", 
                          "Extract the most relevant ", stage_type, " musical with a relevancy score of 100, ",
                          "the one that has the lowest relevancy score but is still related to the topic, ",
                          "and one that has nothing to do with the topic (relevancy score of 0). ",
                          "Display each musical in four lines: ",
                          "On line one, show the name in bold and italics, and without quotes. Then show the year in parenstheses and plain text. ",
                          "On line two, show relevancy description in bold and and the percentage relvancy score in bold. ",
                          "On line three, show the a one or two line description in plain text. ",
                          "Only show the field values (e.g. most relevant), not the field names (e.g. recency score)."
                          ),
  )
  
  # Function to get structured response
  # get_structured_response <- function(prompt) {
  #   chat$extract_data(
  #     prompt,
  #     musicals = musical_schema
  #   )
  # }

  observeEvent(input$chat_user_input, {
    stream <- chat$stream_async(input$chat_user_input)
    chat_append("chat", stream)
  })
}

shinyApp(ui, server)
