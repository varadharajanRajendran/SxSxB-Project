SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_DA_RFIDLog]
		@EquipmentID nvarchar(255)	,
		@EntryID  nvarchar(255)	
AS
 
----------------------------------Declare Variables and Tables----------------------
INSERT INTO [dbo].[SSB_RFIDTagHistory]
           ([EquipmentID]
           ,[EntryID]
           ,[LastUpdated])
     VALUES
           (@EquipmentID,@EntryID,GetDate())
GO
