-- backend/src/db/functions/fn_compute_vibe_score.sql
CREATE OR REPLACE FUNCTION fn_compute_vibe_score(
  a_energy energy_level, a_activity activity_type[],
  b_energy energy_level, b_activity activity_type[],
  overlap_count int,
  distance_km numeric, radius_km int,
  phone_verified boolean, report_rate numeric
) RETURNS numeric LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
  energy_match numeric;
  subtype_match numeric := CASE WHEN overlap_count > 0 THEN 1.0 ELSE 0.0 END;
  interest_overlap numeric := LEAST(overlap_count::numeric / 6.0, 1.0);
  distance_inverse numeric := GREATEST(0, 1.0 - (distance_km / NULLIF(radius_km,0)));
BEGIN
  IF a_energy = b_energy THEN
    energy_match := 1.0;
  ELSIF (a_energy = 'medium' OR b_energy = 'medium') THEN
    energy_match := 0.5;
  ELSE
    energy_match := 0.0;
  END IF;

  RETURN ROUND((
    0.35 * interest_overlap
    + 0.20 * energy_match
    + 0.10 * subtype_match
    + 0.10 * distance_inverse
    + 0.10 * (CASE WHEN phone_verified THEN 1.0 ELSE 0.0 END)
    + 0.10 * (1.0 - LEAST(report_rate, 1.0))
  ) * 100, 2);
END;
$$;
