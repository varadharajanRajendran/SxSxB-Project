CREATE TABLE [dbo].[Temp_PoOrder]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[OrderID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Seq] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Temp_PoOrder] ADD CONSTRAINT [PK_Temp_PoOrder] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
