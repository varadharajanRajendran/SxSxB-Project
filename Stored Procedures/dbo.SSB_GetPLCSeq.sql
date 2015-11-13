SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_GetPLCSeq]
		@StatusID	nvarchar(255)	
AS


DECLARE @tblOrder  AS Table	(	RowId		int	IDENTITY	,
								OrderID		nvarchar(255)	,
								Seq			nvarchar(50)	)

INSERT INTO @tblOrder (orderID,Seq)
	SELECT  Po.pom_order_id,CONVERT(int,Prop.pom_cf_value) from SitmesDB.dbo.POMV_ORDR Po
		INNER JOIN SitmesDB.dbo.POMV_ORDR_PRP_VAL Prop ON Prop.pom_order_id=Po.pom_order_id
	WHERE pom_custom_fld_name='PreactorSequence'
		AND Po.pom_order_status_id = @StatusID
	ORDER BY prop.pom_cf_value asc

DELETE @tblOrder
FROM @tblOrder Po
	INNER JOIN SitmesDB.dbo.POMV_ORDR_PRP_VAL Prop ON Prop.pom_order_id=Po.OrderID
   Where pom_custom_fld_name='SetBCDownload'
	/* 	AND Po.pom_order_status_id = 'PreProduction'  enable when Dyn download is ON  */

SELECT OrderID as OrderId
FROM @tblOrder
	
GO
