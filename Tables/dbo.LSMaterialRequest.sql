CREATE TABLE [dbo].[LSMaterialRequest]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[GroupID] [int] NULL,
[Seq] [int] NULL,
[ProdCell] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProdUnit] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [decimal] (10, 6) NULL,
[UoM] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorageLocation] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsStatic] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitSize] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LSMaterialRequest] ADD CONSTRAINT [PK_LSMaterialRequest] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
