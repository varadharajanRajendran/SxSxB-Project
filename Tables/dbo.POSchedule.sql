CREATE TABLE [dbo].[POSchedule]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Size] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BedType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoreType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Panel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderDec] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MU] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoofSides] [int] NULL,
[CoilDesc] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[Z_1] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Total] [int] NULL
) ON [PRIMARY]
GO
