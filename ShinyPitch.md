Coursera Data Science Capstone 
========================================================
author: Saifeel Momin 
date: 7/20/19
autosize: true

This presentation will outline and pitch the final product for the Coursera Data Science Specializtion capstone project. The main objective of this capstone was to use the provided HC Corpora dataset and develop an application that takes as input a phrase (multiple words) in a text box input and outputs a prediction of the next word. 

Presentation Overview:

1) Explain how your model was built and how it works 

2) Describe the model's predictive performance 

3) Show off the app and how it works 


1. Explain how your model works 
========================================================

Prior to creating a prediction model, the HC Corpora dataset was sampled and cleaned into a consistent format without punctuation, numbers, special characters, URLs, special characters, and capitalization. The cleaned sample was then processed and broken down by a n-gram tokenizer function from the RWeka package. For our model, n-grams of length 2,3, and 4 were identified and saved into individual dataframes. 

The prediction model that was developed takes in raw user input and converts it into the same standard cleaned text format used in our n-gram models. Next the cleaned input is ran through our prediction function which uses the last three words of the input to filter out rows from the quadgram (n = 4) dataframe. If a match is found for each of the three words in the same order, the first word in the fourth column is returned. 

If a match is not found in the quadgram dataframe, the prediction model moves to the trigram dataframe and uses the last two words of the input to filter matching rows and return suggestions. If no matches are found again, the model moves to the bigram dataframe and performs the same search but with only the last word from the input. If no suggestions are returned after the bigram dataframe, the model returns "No predictions based on input" and deactivates all the suggestion buttons. 


2. Describe the model's predictive performance 
========================================================

The predictive model is able to provide at least one accurate suggestion given most input. However, there are still numerous cases where the model fails to provide accurate or useful predictions.  For example, when the input includes a name, the model struggles to return a set of suggestions that are all grammatically accuarte or useful. Furthermore, as the app is hosted on a free shinyapp server we are unable to use larger n-gram dataframes based on larger samples of the HC Corpora data. A larger sample size would allow for greater predictive accuracy but could also reduce the efficiency of our model. 

To improve predictive accuracy, the model was updated to return the top three results rather than just the first. Furthermore, if there are less than 3 suggestions that are returned, the prediction function now works down from the quadgram dataframe to the bigram dataframe looking for additional suggestions. This allows our model to return a greater number of actual suggestions instead of just returning NA. 

Another feature that was added to the model to boost predictive accuracy is the ability for users to add their own suggestions. When the user inputs their own suggestion, it is automatically added to the main input and is also saved into a seperate dataframe consisting of added suggestions only. This new dataframe enables the model to provide suggestions that are personalized to the user. This helps overcome some of the model's difficulty in providing predictions when faced with special cases like names. 


3. Show off the app and how it works
========================================================
right: 60%

As a majority of SwiftKey product consumers are mobile users, simplicity and efficiency were two key  factors taken in consideration while developing the application. To start using the application, users must input a word or phrase into the first text input box **Box 1**. Once a valid phrase has been entered, the application will automatically search for suggestions. If there are any available suggestions, the buttons linked to **Box 2** will be activated and will display the top three (if available) suggestions. If the user wants to use one of the displayed suggestions, they simply click on the button and it will be added to the end of their input. As soon as the suggestion is added, the application will instantaneously search for news suggestions based on the updated input. The last button linked to **Box 3** will only be activated and display a suggestion when there is learned suggestion available. To add a learned suggestion, the user must input *one* word into the text input field at **Box 4** and then simply press the 'Add' button. This will add the new suggestion to the end of the current input and remember it for similar phrases in the future. **Box 6** displays the final output consisting of user input and selected suggestions.
***
![App Demo!](./PresFigures/fig1.png)




Suggestion Learning Demo
========================================================

![App Demo!](./PresFigures/fig2.png)
***
![App Demo!](./PresFigures/fig3.png)
***

Additional Information and Documentation 
========================================================

- The instructions and guidelines for this project, along with additional information, can be found at: 
    - [https://www.coursera.org/learn/data-science-project/home/welcome](https://www.coursera.org/learn/data-science-project/home/welcome)

- All data used for our predicition model came from the HC Corpus dataset. The dataset can be downloaded at:     
    - [https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip)

- All the code, data, and resources used in creation of the app can be found at: [https://github.com/Saifeel/Coursera-Data-Science-Capstone](https://github.com/Saifeel/Coursera-Data-Science-Capstone)

- The text prediction App is hosted at (ENTER RSHINY LINK FOR APP)
