SELECT c.ClienteID, c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-06-30', 'YYYY-MM-DD')
GROUP BY c.ClienteID, c.Nombre
ORDER BY TotalVentas DESC;