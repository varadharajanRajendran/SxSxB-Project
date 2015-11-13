SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetHeader]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @temp table
	(
		BatchNo nvarchar(20)
	)
    -- Insert statements for procedure here
	declare @maxBatch nvarchar(20)
	select @maxBatch = max(batchno) from dbo.SSB_Preactor2MES_Header where ready = 1
	insert into @temp select batchno from dbo.SSB_Preactor2MES_Header where batchno != @maxBatch and ready = 1
	delete dbo.SSB_Preactor2MES_Header where batchno != @maxBatch 
	delete dbo.SSB_Preactor2MES_Details where batchno in (select batchno from @temp tmp)
	
	select * from dbo.SSB_Preactor2MES_Header where ready = 1 and batchno = @maxBatch
END
GO
