{
  "ClienteID": 1,
  "Nombre": "Juan Pérez",
  "Ciudad": "Santiago",
  "FechaNacimiento": "1990-05-15",
  "Pedidos": [
    {
      "PedidoID": 101,
      "Total": 2272.5,
      "FechaPedido": "2025-03-01",
      "Detalles": [
        { "ProductoID": 1, "Nombre": "Laptop", "Precio": 1200, "Cantidad": 2 },
        { "ProductoID": 2, "Nombre": "Mouse", "Precio": 25, "Cantidad": 5 }
      ]
    }
  ]
}




--actividad 2

db.clientes.find(
  { "Ciudad": "Santiago" },
  { "Nombre": 1, "Ciudad": 1, "_id": 0 }
);

db.clientes.aggregate([
  { $unwind: "$Pedidos" },
  { $unwind: "$Pedidos.Detalles" },
  {
    $group: {
      _id: "$Pedidos.Detalles.Nombre",
      TotalVendidos: { $sum: "$Pedidos.Detalles.Cantidad" }
    }
  }
]);