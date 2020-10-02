#
#  This is a Shiny web application. 
#  You can run the application by load the app into RStudio and clicking the 'Run App' button above.
#
#  The aim of the app is to:
#      - read mass spectra (.msp - files)
#      - extract the relevant information
#      - convert the structure into a table
#      - show the mass spectra for individual compounds
#
#  Author: Matthias Pietzke -  matthias.pietzke@gmail.com
#
#  To Do: - deal with multiple entries of the compounds 

library(shiny)
library(shinythemes)
library(tidyverse)
library(plotly)

# Define UI for application that draws a histogram
ui = fluidPage(
    theme = shinythemes::shinytheme("spacelab"),

 titlePanel("Mass-Spectra - Viewer"),
    
 sidebarLayout(
   sidebarPanel(
       h4("This app reads mass spectra files (.msp) and allows an easy overview about the content."),
       h4("The compound and peak list can be exported and the mass spectra can checked."),
       br(),
       fileInput("InputFile", "Input file",
                 placeholder = "need to be in .msp-format"),
       br(),
       checkboxInput("SplitEntities", "Split Name into different fields? 
                     Switch off when using different databse-style.", value = TRUE),
       textInput("sep_entries", "Separator between entries in peak list",
                 value = ";"),
       textInput("sep_mass_intens", "Separator between m/z and intensity in peak list",
                 value = " "),
       h4(textOutput("Stats")),
       downloadButton("DL_Table",
                      "Download Table as .csv")

        ),   # Sidebarpanel
        
  mainPanel(
        tabsetPanel(
          tabPanel("Table",
                   br(),
                   DT::dataTableOutput("Table")  ), 
          tabPanel("Spectra",
                   br(),
             fluidRow(
             column(width = 7,
                    uiOutput("CompoundSelector")) #,
    #         column(width = 5,
    #             selectInput("Replicate", "Select one of the replicates to show",
    #                         choices = c("1","2","3","4","5")))
             ),
             fluidRow(
             column(width = 4,
                    sliderInput("topMasses", "Show top N masses:", 
                                min = 0, max = 30, value = 10, step =1),
                    h4("Comments:"),
                    verbatimTextOutput("Comments")),
             column(width = 8,
                    plotlyOutput("Spectra"))
             )) # tab sepctra

            
        )) # Main Panel
    ) # sidebarlayout
) # UI

# Define server logic required to draw a histogram
server = function(input, output) {
    
    # Imort data
    InputFile = reactive({ 
        infile <- input$InputFile
        if (is.null(infile)) {  
            return(NULL) 
        } else {
            return(read_msp(input$InputFile$datapath))        
        } 
     })
    
    # show base stats for file
    output$Stats = renderText({
        req(InputFile())
        paste0("The uploaded dataset contains ", length(unique(InputFile()$Name)),
               " unique compounds with ", length(InputFile()$Peaks),
               " spectra.")
    })
    
    # processed table - split Name into identifier
    # this works only when the Kempa-Ident naming rules are fulfilled
    # this can also be a good check for consistency!
    FinalTable = reactive({
      req(InputFile())
      
      if (input$SplitEntities == TRUE) {
        FinalTable = InputFile() %>% 
            mutate(Name = str_remove(Name, "RI:"),
                   Name = str_remove(Name, regex("Ident:", ignore_case = TRUE))) %>% 
            separate(Name, into = c("Compound", "Derivative", "Product", "RI", "Ident"),
                     sep = "_")
      } else FinalTable = InputFile()
    })

    # results table
    output$Table = DT::renderDataTable(FinalTable())
    
    # download results
    output$DL_Table = downloadHandler(
        filename = "Table.csv",
        content = function(file) {
            write_csv(FinalTable() , file) },
        contentType = "file/csv" )
    
    # compound list for the selection
    CompoundList = reactive({
        req(InputFile())
        sort(InputFile()$Name)
        })
    
    output$CompoundSelector = renderUI({
        req(InputFile())
        selectInput("Compound", "Select the compound to show",
                    CompoundList(), multiple = FALSE,
                    width = "100%")
    })

    # filtered table
    Results = reactive({
        req(InputFile())
        req(input$Compound)
    
    filter(InputFile(), Name == input$Compound)
    })
    
    # show comments for selected compound
    output$Comments = renderText({
        req(Results())
            pull(Results(), Comments)
    })
    
    output$Spectra = renderPlotly({
        req(Results())
        
      spectra_sep = paste0(input$sep_mass_intens, "+")  
      
      #sep_mass_intens
        spectra_df = Results() %>% 
            select(Peaks) %>% 
            separate_rows(Peaks, sep = input$sep_entries) %>%
            #mutate(Data = str_trim(Data, side = "both")) %>% 
            separate(Peaks, into = c("Mass", "Intensity"),
                     sep = spectra_sep,
                     convert = TRUE) %>% 
            filter(!is.na(Intensity)) %>% 
            arrange(desc(Intensity)) %>% 
            mutate(Rank = rank(desc(Intensity), ties.method = "first" ))
        
        ggplotly(ggplot(spectra_df, aes(x= Mass, y = Intensity)) +
            geom_col(width = 0.8) + 
            theme_classic(base_size = 16) + 
            geom_text(data = filter(spectra_df, Rank <= input$topMasses), 
                      aes(label = Mass, y = Intensity + 30), 
                      check_overlap = TRUE) + 
            labs(x = "m/z",
                 title = paste0("\n", input$Compound)) +
          theme(plot.title = element_text(hjust = 0.5,size = 12))
        )
        })
    
} # Server 

# Define the functions:
read_msp = function(inputfile) {

    ## Read in the msp
    input = read_file(inputfile) %>%
        str_replace_all("\r*\n", "\n") %>% 
        str_remove("\n\n$")   # remove empty line at the end
    
    ## transform the file for better readability:
    # split the different entries, separated by a blank line
    input2 = str_split(input, "\n\n", simplify = FALSE)  # generates list
    
    input3 = unlist(input2)                                  # back to character vector
    
    ## extract the important information
    # extract compound names: everything between "Name:" and the next line break
    names = str_extract(input3, regex("(?<=^(Name|NAME|name): ).*(?=\n)", # somehow ignore case doesnt work?
                        ignore_case = TRUE))  
    
    # the next steps aren't very elegant but work
    # remove the names from the input (as this nicely ends with a line break)
    # line breaks mess up with the extraction of the other features, 
    # so replace line-breaks by "___" to restore them later 
    
    input_wo_names = str_remove(input3, regex("^(Name|NAME|name): .*\n", ignore_case = TRUE)) %>%  
        str_replace_all("\n","___")
    
    # extract comments: everything from after the name and (including "Num Peaks: NNN)
    # then restore line breaks
    comments = str_replace_all(str_extract(input_wo_names,
                                           regex(
                                           ".*Num Peaks: *\\d{1,3}", ignore_case = TRUE)), 
                               "___", "\n")
    
    #extract peaks: everything after "Num Peaks: NNN" to the end
    peaks = str_extract(input_wo_names,
                        regex("(?<=Num Peaks: \\d{1,3}___).*" , ignore_case = TRUE))
    # clean up, remove unneeded symbols
    peaks = str_replace_all(peaks,
                            c("___" = "",     # old line breaks
                              "; *" = ";",    # empty space after semicolon
                              "^ *" = "",     # empty space in front of first number
                              ";$" = ""))     # ending semicolon in last row
    
    # create a dataframe by combining the 3 vectors:
    msp_as_df = tibble("Name" = names,
                       "Comments" = comments,
                       "Peaks" = peaks) %>% 
      #mutate(RI=str_replace_all(Name,".*RI:(\\d+)_.*","\\1")) %>% 
      select(Name,Comments,Peaks)
    
    # check the results:
    if (is.data.frame(msp_as_df) & all(colnames(msp_as_df) == c("Name", "Comments", "Peaks")) == TRUE) {
        print(paste0("Done! ", length(unique(msp_as_df$Name)),
                     " unique compounds with ", length(msp_as_df$Peaks),
                     " spectra imported"))
        
        return(msp_as_df)
    } else {
        print("Error, conversion failed!")
        return(msp_as_df) }
    
}  # Function read_msp


# Run the application 
shinyApp(ui = ui, server = server)
