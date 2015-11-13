SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[LS_GetProdUnit]
        @ProdCell	nvarchar(255)	
AS

SELECT Distinct([ProdUnit])
  FROM [SSB].[dbo].[LSMaterialRequest]
  Where [ProdCell]=@ProdCell
GO
