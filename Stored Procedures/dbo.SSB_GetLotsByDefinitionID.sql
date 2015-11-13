SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SSB_GetLotsByDefinitionID]
	-- Add the parameters for the stored procedure here
	@EntryID nvarchar(MAX),
	@DefID nvarchar(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select	*
from	SitMesDb.dbo.MMLotCommitTo c inner join SitMesDb.dbo.MMvLots l on c.LotPK = l.LotPK
		inner join SitMesDb.dbo.MMvDefVers defver on  l.DefVerPK = defver.DefVerPK
		inner join SitMesDb.dbo.MMvDefinitions def on def.DefPK = defver.DefPK
		inner join SitMesDb.dbo.MMvLocations loc on l.LocPK = loc.LocPK
where			
		c.CommitTo = @EntryID
		AND def.DefID = @DefID
END
GO
