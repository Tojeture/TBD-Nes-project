MetaTileSeta00:
 .db $00,$00,$00,$00,$00,%00000000 
MetaTileSeta01:
 .db $01,$75,$01,$01,$00,%00001111
MetaTileSeta02:
 .db $05,$05,$06,$06,$02,%00001111

MetaTileSeta:
 .dw MetaTileSeta00,MetaTileSeta01,MetaTileSeta02
Map0:
 .dw Map01,Map00
 
Map00:
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$00,$FF
 .db $8F,$01,$FF
 .db $8F,$01,$FF
 .db $8F,$01,$FF

Map01:
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8F,$7F,$FF
 .db $8A,$02,$85,$00,$FF
 .db $8A,$01,$85,$00,$FF