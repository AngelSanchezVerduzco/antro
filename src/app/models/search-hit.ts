export interface SearchHit {
  id: string;
  tipo: string;
  titulo: string;
  descripcion: string;
  categoria: string;
  ruta: string;
  score?: number;
  highlight?: string;
}

export interface SearchResponse {
  total: number;
  hits: SearchHit[];
  error?: string;
}
