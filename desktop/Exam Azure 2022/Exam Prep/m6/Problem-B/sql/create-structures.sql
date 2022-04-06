CREATE TABLE SubmittedItems (
 ID INT IDENTITY(1,1), 
 SubmissionTime datetime DEFAULT getdate(), 
 SubmittedName VARCHAR(50), 
 PRIMARY KEY (ID)); 
 
GO
 
INSERT INTO SubmittedItems (SubmittedName) VALUES ('INITIAL');

GO