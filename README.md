# Categories Experiment



Hi Gabby, 
1 - To replicate AG-L results, 
	```matlab 
	cd Categories_Experiment
	addpath(Scripts)
	addpath(Gabby-Scripts)
	Replicate_ROI_RSA.m
	```
Aidas


    ExtractNetRSAdata.m

input: ROI folder: folder with ROI masks 
output: netRSA_data file structure  


![](https://paper-attachments.dropbox.com/s_4191A58C9730849B31B4303A3E4ABB249AC729B33FE307D8D0E526A1A2336220_1563663541996_Screen+Shot+2019-07-20+at+6.57.53+PM.png)



Script to replicate RSA


    Replicate_ROI_RSA.m

Takes in 

- NetRSA_data structure (see above)
- Semantic similarity model (16x16)


Outputs

- dendrogram 
- ROI similarity matrix
- Model fit statistic 


![](https://paper-attachments.dropbox.com/s_4191A58C9730849B31B4303A3E4ABB249AC729B33FE307D8D0E526A1A2336220_1563663259610_Screen+Shot+2019-07-20+at+6.53.14+PM.png)


All the necessary files are included 

![](https://paper-attachments.dropbox.com/s_4191A58C9730849B31B4303A3E4ABB249AC729B33FE307D8D0E526A1A2336220_1563663850383_Screen+Shot+2019-07-20+at+7.01.09+PM.png)



Change this for different ROIs 

![](https://paper-attachments.dropbox.com/s_4191A58C9730849B31B4303A3E4ABB249AC729B33FE307D8D0E526A1A2336220_1563663904218_Screen+Shot+2019-07-20+at+7.01.25+PM.png)


