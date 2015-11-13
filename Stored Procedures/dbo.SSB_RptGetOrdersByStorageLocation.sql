SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[SSB_RptGetOrdersByStorageLocation]
AS

DECLARE @intStartRow	int				,
        @intEndRow		int				,
        @intelProc		int				,
        @OrderID		nvarchar(20)	,	
		@PanelStorage	nvarchar(10)	,	
		@PanelLotID		nvarchar(255)	,	
		@BorderStorage	nvarchar(10)	,	
		@BorderLotID	nvarchar(255)	,	
		@BorderCount	int				,
		@PanelCount		int				,
		@Match			int				,
		@BordernonMatch	int				,
		@PanelNonMatch	int

DECLARE	@tblPanelStorage AS Table	(	RowId			int	IDENTITY	,
									    LocationID		nvarchar(10)	,
									    OrderID			nvarchar(20)	,
									    LotID	        nvarchar(255)	)

DECLARE	@tblBorderStorage AS Table	(	RowId			int	IDENTITY	,
									    LocationID		nvarchar(10)	,
									    OrderID			nvarchar(20)	,
									    LotID	        nvarchar(255)	)

DECLARE	@tblOrders AS Table			(	RowId			int	IDENTITY	,
									    OrderID			nvarchar(20)	)

DECLARE	@tblStorageLoc AS Table	   (	RowId			int	IDENTITY	,
										OrderID			nvarchar(20)	,
									    BorderSID		nvarchar(10)	,
									    PanelSID		nvarchar(10)	,
									    BorderLot	    nvarchar(255)	,
										PanelLot	    nvarchar(255)	)




INSERT INTO @tblBorderStorage
	SELECT 
		REPLACE(e.LocPath,'WPB.CML01.BC01.SL-BHC.','') as [Location ID]	,
		c.CommitTo as [Law Tag No]										,
		l.LotID as [Lot ID]									
	FROM [SitMesDB].[dbo].[MMvLots] l
		INNER JOIN [SitMesDB].[dbo].[MMwLotCommitTo] c on c.LotPK = l.LotPK
		INNER JOIN [SitMesDB].[dbo].[MMvLocations] e on e.LocPK = l.LocPK
		INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] et on et.pom_order_id = c.CommitTo
	WHERE et.pom_entry_type_id = 'BHC'
		   AND e.LocPath like 'WPB.CML01.BC01.SL-BHC.BHC%' 
	ORDER BY REPLACE(e.LocPath,'WPB.CML01.BC01.SL-BHC.%','') ASC

INSERT INTO @tblPanelStorage
	SELECT 
		REPLACE(e.LocPath,'WPB.CML01.PQ01.SL-PQ.','') as [Location ID]	,
		c.CommitTo as [Law Tag No]										,
		l.LotID as [Lot ID]									
	FROM [SitMesDB].[dbo].[MMvLots] l
		INNER JOIN [SitMesDB].[dbo].[MMwLotCommitTo] c on c.LotPK = l.LotPK
		INNER JOIN [SitMesDB].[dbo].[MMvLocations] e on e.LocPK = l.LocPK
		INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] et on et.pom_order_id = c.CommitTo
	WHERE e.LocPath like 'WPB.CML01.PQ01.SL-PQ.%' 
		AND et.pom_entry_type_id = 'OVERCAST'
	ORDER BY REPLACE(e.LocPath,'WPB.CML01.PQ01.SL-PQ.%','') ASC


INSERT INTO @tblOrders
	SELECT 
		DISTINCT(c.CommitTo)																		
	FROM [SitMesDB].[dbo].[MMvLots] l
		INNER JOIN [SitMesDB].[dbo].[MMwLotCommitTo] c on c.LotPK = l.LotPK
		INNER JOIN [SitMesDB].[dbo].[MMvLocations] e on e.LocPK = l.LocPK
		INNER JOIN [SitMesDB].[dbo].[POMV_ETRY] et on et.pom_order_id = c.CommitTo
	WHERE (e.LocPath like 'WPB.CML01.PQ01.SL-PQ.%' OR e.LocPath like 'WPB.CML01.BC01.SL-BHC.BHC%' )
		AND (et.pom_entry_type_id = 'OVERCAST' OR et.pom_entry_type_id = 'BHC')

SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@tblOrders 
    

WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT @orderID=OrderID	
	FROM @tblOrders 
	WHERE RowId=@intStartRow
	
	SELECT 	@PanelStorage	=''	,	
		@PanelLotID		=''	,	
		@BorderStorage	=''	,	
		@BorderLotID	=''	

	SELECT @PanelStorage=LocationID,
		   @PanelLotID=LotID
	FROM @tblPanelStorage
	Where OrderID=@OrderID

	SELECT @BorderStorage=LocationID,
		   @BorderLotID=LotID
	FROM @tblBorderStorage
	Where OrderID=@OrderID

	INSERT INTO @tblStorageLoc (OrderID, BorderSID, PanelSID,BorderLot,PanelLot)
		VALUES(@OrderID,@BorderStorage,@PanelStorage,@BorderLotID,@PanelLotID)
	

	SELECT @intStartRow=@intStartRow +1
END

SELECT @BorderCount=COUNT(RowID)
FROM @tblStorageLoc 
WHERE BorderSID is Not NULL

SELECT @PanelCount=COUNT(RowID)
FROM @tblStorageLoc 
WHERE PanelSID is Not NULL


SELECT @BordernonMatch=COUNT(RowID)
FROM @tblStorageLoc 
WHERE BorderSID =''

SELECT @PanelNonMatch=COUNT(RowID)
FROM @tblStorageLoc 
WHERE PanelSID =''

SELECT @Match=COUNT(RowID)
FROM @tblStorageLoc 
WHERE (BorderSID <>''
	AND PanelSID <>'')



SELECT OrderID, 
	   BorderSID, 
	   PanelSID,
	   BorderLot,
	   PanelLot 
FROM @tblStorageLoc 

SELECT  @BorderCount as [Borders Produced],
		@BordernonMatch as [Border Yet to Produce],
		@PanelCount as [Panels Produced],
		@PanelNonMatch as [Panels Yet to Produce],
		@Match as [Match]
GO
