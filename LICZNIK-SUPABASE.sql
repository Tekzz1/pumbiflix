-- Wklej ten kod w Supabase > SQL Editor i uruchom RUN.
-- Licznik wizyt (jedna wizyta na kartę przeglądarki).
CREATE TABLE IF NOT EXISTS public.licznik_odwiedzin (
 id integer PRIMARY KEY CHECK (id = 1),
 liczba bigint NOT NULL DEFAULT 0 CHECK (liczba >= 0)
);
INSERT INTO public.licznik_odwiedzin(id,liczba) VALUES (1,0) ON CONFLICT (id) DO NOTHING;
ALTER TABLE public.licznik_odwiedzin ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.licznik_odwiedzin FROM anon, authenticated;
CREATE OR REPLACE FUNCTION public.licz_odwiedziny(nalicz boolean DEFAULT true)
RETURNS bigint LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE wynik bigint;
BEGIN
 IF nalicz THEN
  UPDATE public.licznik_odwiedzin SET liczba = liczba + 1 WHERE id = 1 RETURNING liczba INTO wynik;
 ELSE
  SELECT liczba INTO wynik FROM public.licznik_odwiedzin WHERE id = 1;
 END IF;
 RETURN wynik;
END; $$;
REVOKE ALL ON FUNCTION public.licz_odwiedziny(boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.licz_odwiedziny(boolean) TO anon, authenticated;
-- Uwaga: to licznik wizyt, nie unikalnych osób. Publiczne wywołania mogą zawyżać wynik.
