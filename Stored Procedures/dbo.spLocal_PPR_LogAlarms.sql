SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spLocal_PPR_LogAlarms]
	@ErrorDescription1		nvarchar(255)	,
	@ErrorDescription2		nvarchar(255)	
AS

 DECLARE @LogDate DateTime,
		@ExGroup nvarchar(50),
		@ExDescription nvarchar(255),
		@ExDescription2 nvarchar(255),
        @MESFunctionality nvarchar(255),
        @ExUser1 nvarchar(50),
		@ExUser2 nvarchar(50),
        @ExUser3 nvarchar(50),
        @Status int

SELECT  @LogDate=GETDATE(),
		@ExGroup ='Alarm',
		@ExDescription =@ErrorDescription1	,
		@ExDescription2=@ErrorDescription2,
        @MESFunctionality ='PDefM-PPR Rule',
        @ExUser1 ='Production Manager',
		@ExUser2 ='Administrator',
        @ExUser3='',
        @Status=1
		
INSERT INTO SSB_ExceptionLog
 VALUES (@ExGroup,@ExDescription,@ExDescription2,@MESFunctionality,GETDATE(),
		@ExUser1,@ExUser2,@ExUser3,@Status,'','','')
RETURN
GO
