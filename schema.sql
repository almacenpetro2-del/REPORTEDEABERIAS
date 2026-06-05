-- ============================================================
-- Schema para Petroexpress - Control de Desperfectos
-- Base de datos: Supabase (PostgreSQL)
-- ============================================================

-- Tabla de flota (unidades/vehículos)
CREATE TABLE fleet (
  id SERIAL PRIMARY KEY,
  plate VARCHAR(20) NOT NULL UNIQUE,
  description TEXT,
  type VARCHAR(50),
  brand VARCHAR(50),
  year VARCHAR(10),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de conductores
CREATE TABLE drivers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de desperfectos
CREATE TABLE defects (
  id SERIAL PRIMARY KEY,
  date_report DATE NOT NULL,
  time_report TIME NOT NULL,
  plate VARCHAR(20) NOT NULL REFERENCES fleet(plate) ON DELETE CASCADE,
  driver VARCHAR(255) NOT NULL,
  description TEXT,
  system VARCHAR(50) CHECK (system IN ('ELÉCTRICO', 'HIDRÁULICO', 'NEUMÁTICOS', 'OTRO')),
  severity VARCHAR(20) CHECK (severity IN ('LEVE', 'MODERADO', 'GRAVE')),
  date_repair DATE,
  time_repair TIME,
  status VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (status IN ('PENDIENTE', 'EN REPORTE', 'EN TALLER', 'REPARADO')),
  observations TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para búsquedas frecuentes
CREATE INDEX idx_defects_plate ON defects(plate);
CREATE INDEX idx_defects_status ON defects(status);
CREATE INDEX idx_defects_date_report ON defects(date_report);
CREATE INDEX idx_defects_severity ON defects(severity);
CREATE INDEX idx_defects_system ON defects(system);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_defects_updated_at
  BEFORE UPDATE ON defects
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- POLÍTICAS RLS (Row Level Security) para acceso anon
-- ============================================================

ALTER TABLE fleet ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE defects ENABLE ROW LEVEL SECURITY;

-- Fleet: acceso público total (lectura/escritura)
CREATE POLICY "anon_select_fleet" ON fleet FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert_fleet" ON fleet FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update_fleet" ON fleet FOR UPDATE TO anon USING (true);
CREATE POLICY "anon_delete_fleet" ON fleet FOR DELETE TO anon USING (true);

-- Drivers: acceso público total
CREATE POLICY "anon_select_drivers" ON drivers FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert_drivers" ON drivers FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update_drivers" ON drivers FOR UPDATE TO anon USING (true);
CREATE POLICY "anon_delete_drivers" ON drivers FOR DELETE TO anon USING (true);

-- Defects: acceso público total
CREATE POLICY "anon_select_defects" ON defects FOR SELECT TO anon USING (true);
CREATE POLICY "anon_insert_defects" ON defects FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon_update_defects" ON defects FOR UPDATE TO anon USING (true);
CREATE POLICY "anon_delete_defects" ON defects FOR DELETE TO anon USING (true);

-- ============================================================
-- DATOS INICIALES (seed)
-- ============================================================

INSERT INTO fleet (plate, description, type, brand, year) VALUES
  ('BWR-724', 'Unidad Compacta 1', 'COMPACTA', 'SHACMAN', '2023'),
  ('BWP-886', 'Unidad Compacta 2', 'COMPACTA', 'SHACMAN', '2023'),
  ('BWQ-764', 'Unidad Compacta 3', 'COMPACTA', 'SHACMAN', '2023'),
  ('BWP-917', 'Unidad Compacta 4', 'COMPACTA', 'SHACMAN', '2023'),
  ('BWQ-863', 'Unidad Compacta 5', 'COMPACTA', 'SHACMAN', '2023'),
  ('BZV-711', 'Unidad Compacta 6', 'COMPACTA', 'SHACMAN', '2024'),
  ('BZV-736', 'Unidad Compacta 7', 'COMPACTA', 'SHACMAN', '2024'),
  ('BZU-913', 'Unidad Compacta 8', 'COMPACTA', 'SHACMAN', '2024'),
  ('CBJ-823', 'Cisterna 1', 'CISTERNA', 'FOTON', '2025'),
  ('CBN-920', 'Cisterna 2', 'CISTERNA', 'FOTON', '2025'),
  ('BMB-818', 'Hidrolavado 1', 'HIDROLAVADO', 'DONGFENG', '2022'),
  ('BMB-794', 'Hidrolavado 2', 'HIDROLAVADO', 'DONGFENG', '2022'),
  ('BMD-830', 'Hidrolavado 3', 'HIDROLAVADO', 'DONGFENG', '2022'),
  ('BMA-793', 'Hidrolavado 4', 'HIDROLAVADO', 'DONGFENG', '2022'),
  ('BMC-738', 'Hidrolavado 5', 'HIDROLAVADO', 'DONGFENG', '2022'),
  ('BMB-902', 'Baranda 1', 'BARANDA', 'DONGFENG', '2022'),
  ('N°1', 'Barredora N°1', 'BARREDORA MECÁNICA', 'NILFISK', '2024'),
  ('N°2', 'Barredora N°2', 'BARREDORA MECÁNICA', 'NILFISK', '2024'),
  ('N°3', 'Barredora N°3', 'BARREDORA MECÁNICA', 'NILFISK', '2024'),
  ('N°4', 'Fregadora N°1', 'FREGADORA MECÁNICA', 'NILFISK', '2024'),
  ('N°5', 'Fregadora N°2', 'FREGADORA MECÁNICA', 'NILFISK', '2024'),
  ('V2Q-773', 'Unidad Adicional 1', 'CISTERNA COMBUSTIBLE', 'N/D', 'N/D'),
  ('C7I-730', 'Unidad Adicional 2', 'CISTERNA COMBUSTIBLE', 'N/D', 'N/D'),
  ('BRH-906', 'Unidad Adicional 3', 'N/D', 'N/D', 'N/D');

INSERT INTO drivers (name) VALUES
  ('ALCCA CCAHUANA NEPTALI ROLANDO'),
  ('ARAUJO QUISPE EDGAR'),
  ('ARROYO DELGADO JHON ROYNER'),
  ('ASCANOA CONDOR DANIEL'),
  ('BARRIOS ALVAREZ DAVID'),
  ('CHIRINOS GONZALES MARCO ANTONIO'),
  ('CURIPACO MALLMA FRANCO SONY'),
  ('GOICOCHEA SALCEDO GUILLERMO'),
  ('GOMEZ ROCA FERNANDO'),
  ('GRILLET ARGENIS RAMON'),
  ('GUTIERREZ HUANAY JORGE LUIS'),
  ('JERI CHAVEZ GUSTAVO ORLANDO'),
  ('LLACTAHUAMAN GUERRERO WALTER'),
  ('MARRON BALDEON JOSE MANUEL'),
  ('MARTINEZ LEANDRO JORGE LUIS'),
  ('MIRAVAL RODENAS JORGE VISA'),
  ('PALOMINO ASTO JHON GELVERT'),
  ('PALOMINO CAJA JOSE ARISTIDES'),
  ('PAUCAR AGUILERA DIEGO'),
  ('QUISPE PERALES CHRISTHIAN AMERICO'),
  ('RIVERA HUANUQUEÑO GERSON MARIO'),
  ('ROBLES GORA SANTIAGO'),
  ('SANTIAGO MURGA MAXIMO'),
  ('VALDERRAMA CAMILO DANI DANIEL'),
  ('VELASQUEZ MAMANI WALTER'),
  ('TUPAC VILLEGAS ROBBY');

INSERT INTO defects (id, date_report, time_report, plate, driver, description, system, severity, date_repair, time_repair, status, observations) VALUES
  (1, '2026-06-02', '06:15', 'N°1', 'JERI CHAVEZ GUSTAVO ORLANDO', 'LUCES NO FUNCIONAN', 'ELÉCTRICO', 'MODERADO', '2026-06-03', '06:00', 'REPARADO', ''),
  (2, '2026-06-02', '06:15', 'N°1', 'JERI CHAVEZ GUSTAVO ORLANDO', 'LLANTA POSTERIOR ESTA DESGASTADA', 'NEUMÁTICOS', 'LEVE', NULL, NULL, 'PENDIENTE', ''),
  (3, '2026-06-02', '03:46', 'N°4', 'ARAUJO QUISPE EDGAR', 'JEBE LATERAL PARA CAMBIO', 'OTRO', 'MODERADO', NULL, NULL, 'PENDIENTE', 'SE SOLICITO EL JEBE'),
  (4, '2026-06-02', '15:03', 'BZV-736', 'PALOMINO ASTO JHON GELVERT', 'fuga de hidrolina por bomba hidraulica', 'HIDRÁULICO', 'GRAVE', '2026-06-04', '17:00', 'REPARADO', ''),
  (5, '2026-06-02', '22:23', 'BWP-886', 'MARRON BALDEON JOSE MANUEL', 'Roto puño de la base del piston hidrulico', 'HIDRÁULICO', 'GRAVE', '2026-06-02', '15:15', 'REPARADO', ''),
  (6, '2026-06-03', '09:13', 'BZU-913', 'QUISPE PERALES CHRISTHIAN AMERICO', 'rotura de manguera hidraulica', 'HIDRÁULICO', 'MODERADO', '2026-06-03', '08:44', 'REPARADO', 'Axilio Freddy Reyes'),
  (7, '2026-06-03', '10:52', 'BWR-724', 'ALCCA CCAHUANA NEPTALI ROLANDO', 'Fuga aceite del motor', 'HIDRÁULICO', 'MODERADO', '2026-06-03', '11:22', 'REPARADO', 'Auxilio mecanico'),
  (8, '2026-06-03', '13:18', 'BWR-724', 'ALCCA CCAHUANA NEPTALI ROLANDO', 'Bolsa de aire del asiento del piloto', 'OTRO', 'LEVE', '2026-06-03', '14:20', 'REPARADO', ''),
  (9, '2026-06-04', '09:37', 'BWQ-863', 'MARRON BALDEON JOSE MANUEL', 'Resume hidrolina por cañeria de metal del techo', 'HIDRÁULICO', 'GRAVE', NULL, NULL, 'EN TALLER', 'INGRESA 15:43'),
  (10, '2026-06-04', '09:52', 'BZU-913', 'ROBLES GORA SANTIAGO', 'fuga de lexiviado por llave de paso la de tina', 'OTRO', 'MODERADO', '2026-06-04', '14:16', 'REPARADO', ''),
  (11, '2026-06-05', '07:34', 'N°1', 'JERI CHAVEZ GUSTAVO ORLANDO', 'baja mucho mas de su nivel', 'OTRO', 'MODERADO', NULL, NULL, 'EN REPORTE', ''),
  (12, '2026-06-05', '06:31', 'BZV-736', 'QUISPE PERALES CHRISTHIAN AMERICO', 'manija interna de puerta del conductor es malograda', 'OTRO', 'LEVE', NULL, NULL, 'EN REPORTE', ''),
  (13, '2026-06-05', '07:34', 'BWR-724', 'TUPAC VILLEGAS ROBBY', 'fuga de lexiviado por llave de paso la de tina', 'OTRO', 'LEVE', NULL, NULL, 'EN REPORTE', '');

-- Ajustar la secuencia del id después del seed manual
SELECT setval('defects_id_seq', (SELECT MAX(id) FROM defects));

-- ============================================================
-- CONSULTAS ÚTILES (referencia)
-- ============================================================

-- Desperfectos por unidad (última incidencia)
/*
SELECT 
  f.plate,
  f.description,
  f.type,
  d.date_report AS ultima_fecha,
  d.description AS ultimo_desperfecto,
  d.system,
  d.severity,
  d.driver AS ultimo_conductor,
  CASE WHEN EXISTS (
    SELECT 1 FROM defects d2 
    WHERE d2.plate = f.plate AND d2.status = 'EN TALLER'
  ) THEN '🔴 INOPERATIVA' ELSE '🟢 OPERATIVA' END AS estado_actual,
  COUNT(d.id) AS total_desperfectos
FROM fleet f
LEFT JOIN LATERAL (
  SELECT * FROM defects 
  WHERE plate = f.plate 
  ORDER BY date_report DESC, time_report DESC 
  LIMIT 1
) d ON true
GROUP BY f.plate, f.description, f.type, d.date_report, d.description, d.system, d.severity, d.driver
ORDER BY f.plate;
*/

-- Estado de la flota
/*
SELECT 
  f.plate,
  f.description,
  f.type,
  f.brand,
  f.year,
  CASE WHEN EXISTS (
    SELECT 1 FROM defects d WHERE d.plate = f.plate AND d.status = 'EN TALLER'
  ) THEN '🔴 INOPERATIVA' ELSE '🟢 OPERATIVA' END AS estado,
  COUNT(d.id) AS total_desperfectos
FROM fleet f
LEFT JOIN defects d ON f.plate = d.plate
GROUP BY f.plate, f.description, f.type, f.brand, f.year
ORDER BY f.plate;
*/
