SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[LS_GetProdCell]
AS

SELECT Distinct([ProdCell])
  FROM [SSB].[dbo].[LSMaterialRequest]
GO
