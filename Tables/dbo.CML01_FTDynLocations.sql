CREATE TABLE [dbo].[CML01_FTDynLocations]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[LocationAlias] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CML01_FTDynLocations] ADD CONSTRAINT [PK_CML01_FTDynLocations] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO