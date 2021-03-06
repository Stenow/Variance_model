library(tidyverse) # run install.packages('tidyverse') in the console if you don't have it installed
library(TTR)  #run install.packages('TTR') in the console if you don't have it installed
library(gridExtra)


# Imput settings ----------------------------------------------------------


Mean_average  <-5.38     #The average used in the model
Variance_sd <-2.07       #The sd used in the model
Number_of_samples <- 50  #The maximum number of samples
Number_of_runs <- 30    #Number of times to run the model
Number_of_samples_acctually_taken  <- NaN #The number of samples actually taken, adds a vertical line for them in the graph, remove it by setting it to NaN




# Defining dataframes -----------------------------------------------------


Raw_dataframe <- data.frame(matrix(0, ncol = Number_of_runs, nrow = Number_of_samples))  #Create a dataframe for the simulated data
Sliding_mean <-data.frame(matrix(0, ncol = Number_of_runs, nrow = Number_of_samples)) #Create a dataframe for the sliding average
Sliding_sd <-data.frame(matrix(0, ncol = Number_of_runs, nrow = Number_of_samples)) #Creating a dataframe for the slding sd, right now im not using the sd 



# Create mock data --------------------------------------------------------


for (i in 1:Number_of_samples) {
  
  
  Raw_dataframe[i,]<- rnorm(Number_of_runs, mean=Mean_average, sd=Variance_sd)  #Create the simulated data 100 tines for the length of the empty dataframe
  
  }




# Calculated sliding average ----------------------------------------------



for (i in 1:Number_of_runs) { 
  
  Sliding_mean[,i]  <- runMean(Raw_dataframe[,i], n=1, cumulative = TRUE) #Create the sliding mean, cumulative adds the new number each time, n determines when the firs value should be 
  Sliding_sd[,i] <- runSD(Raw_dataframe[,i], n=1, cumulative = TRUE) #same but for sd
  
}




# Reformat data for ggplot  -----------------------------------------------


data_long <- gather(Sliding_mean)  #this rearange the data to a format that can acctually be plotted
data_long$n_sample <- rep(1:Number_of_samples, times=Number_of_runs) # This adds the number of samples that is used for the average

data_long_sd <- gather(Sliding_sd)
data_long_sd$n_sample <- rep(1:Number_of_samples, times=Number_of_runs)
data_long_se <- data_long_sd
data_long_se$value <- data_long_se$value/sqrt(data_long_se$n_sample)



# Plotalot ----------------------------------------------------------------

#Plot average
Figure_a <- ggplot(data_long, aes(x=n_sample, y=value, color=key))+  #it is okay to get a error message that they removed rows equl to the number of runs (its becouse the first average is blank)
  geom_point(show.legend = FALSE, alpha=0.5)+
  geom_vline(aes(xintercept=Number_of_samples_acctually_taken), color="blue")+ #Enable this line and set the value of samples used to show that on the graph 
  geom_hline(aes(yintercept=Mean_average))+
  geom_hline(aes(yintercept=Mean_average-(Variance_sd/3)), linetype="dashed")+  ##The errorbars are 1/3 of sd, to line up with the final derivation, might want to change that
  geom_hline(aes(yintercept=Mean_average+(Variance_sd/3)),linetype="dashed")+
  scale_y_continuous(limits = c(0,Mean_average+Variance_sd*2), n.breaks = 7)+
  xlab(" ")+
  ylab("Mean value")+
  theme_classic()+
  annotate("text", x = Number_of_samples/2, y = Mean_average+Variance_sd*1.5, label = paste("Mean value:",Mean_average,  #This adds the values assigned as the settings for the model, the paste comand ties it together
                                                                                         "\ \nVariance sd:", Variance_sd, #\ \n in a string makes a new row, note the spaces between \ \!
                                                                                         "\ \n Max number of samples:", Number_of_samples,
                                                                                         "\ \n Number of runs:", Number_of_runs))
  

#Plot sd

Figure_sd <- ggplot(data_long_sd, aes(x=n_sample, y=value, color=key))+  #it is okay to get a error message that they removed rows equl to the number of runs (its becouse the first average is blank)
  geom_point(show.legend = FALSE, alpha=0.5)+
  geom_vline(aes(xintercept=Number_of_samples_acctually_taken), color="blue")+ #Enable this line and set the value of samples used to show that on the graph 
  geom_hline(aes(yintercept=Variance_sd))+
  scale_y_continuous(limits = c(0,Variance_sd*2.5), n.breaks = 7)+
  xlab("Number of samples taken")+
  ylab("Standard deviation")+
  theme_classic()


#Plot se
Figure_se <- ggplot(data_long_se, aes(x=n_sample, y=value, color=key))+  #it is okay to get a error message that they removed rows equl to the number of runs (its becouse the first average is blank)
  geom_point(show.legend = FALSE, alpha=0.5)+
  geom_vline(aes(xintercept=Number_of_samples_acctually_taken), color="blue")+ #Enable this line and set the value of samples used to show that on the graph 
  #geom_hline(aes(yintercept=Variance_sd))+
  scale_y_continuous(limits = c(0,Variance_sd*2.5), n.breaks = 7)+
  xlab("Number of samples taken")+
  ylab("Standard error")+
  theme_classic()

#Show them both in one figure
Figure_average_sd <- grid.arrange(Figure_a,Figure_sd)
Figure_average_se <- grid.arrange(Figure_a,Figure_se)
Figure_average_sd_se <- grid.arrange(Figure_a,Figure_sd, Figure_se)

#Lugol_stats <- data.frame("Experiment"= c("EXP","STAT","LSTAT_NH4", "LSTAT_NO3"), "Mean_c_length" = c(5.3807, 3.8943, NaN, NaN), "Variance_c_length" = c(2.0677, 1.6253,NaN,NaN))
