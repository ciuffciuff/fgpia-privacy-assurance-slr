# Formulário de extração — RSL Grupo 1 (GQPC 2026.2)

Objetivo da RSL: fundamentar a FGP-IA, extensão de garantia de privacidade baseada em risco do CRISP-ML(Q).

Questões de pesquisa
- QP1 (Processo): Como modelos de processo / ciclos de vida de IA/ML tratam privacidade e proteção de dados?
- QP2 (Cobertura): Quais atividades de privacidade são prescritas, com critérios de verificação e artefatos, e em quais fases do ciclo?
- QP3 (Lacunas): Que lacunas há entre requisitos normativos de privacidade (GDPR, LGPD, AI Act etc.) e tarefas de engenharia?
- QP4 (Mecanismos): Que tarefas, critérios de aceitação e artefatos podem ancorar uma extensão baseada em risco do CRISP-ML(Q)?

Fases do CRISP-ML(Q) (Studer et al., 2021) — use estes códigos:
- F1 = Business & Data Understanding (entendimento do negócio e dos dados; requisitos, viabilidade, coleta)
- F2 = Data Engineering / Data Preparation (seleção, limpeza, anonimização, feature engineering)
- F3 = ML Model Engineering (treino, escolha de modelo, DP no treino, FL etc.)
- F4 = ML Model Evaluation / QA (avaliação, testes, auditoria, ataques de inferência)
- F5 = Deployment (implantação, serving, controle de acesso, inferência segura)
- F6 = Monitoring & Maintenance (monitoramento, retreino, desaprendizado, retenção/descartes)
- TRANSV = transversal/governança (sem fase específica)

Avaliação de qualidade (baseada em Kitchenham & Charters, 2007; escala 1 = sim, 0,5 = parcialmente, 0 = não)
- QA1: Objetivos e contribuição estão claramente declarados?
- QA2: O método de pesquisa (ou de construção da proposta) está descrito e é adequado ao objetivo?
- QA3: Os achados/proposta foram avaliados empiricamente (estudo de caso, experimento, avaliação com especialistas, dados reais)? (0,5 = exemplo ilustrativo/prova de conceito simples)
- QA4: Há rastreabilidade explícita entre requisitos normativos (artigos de lei, normas ISO, guias) e as atividades/controles propostos?
- QA5: O estudo trata explicitamente o ciclo de vida de IA/ML por fases (não apenas privacidade de dados em geral)?
Escore total = soma (0 a 5). Justifique cada nota em uma frase.

## Saída — um arquivo JSON por estudo, em `extr/Sxx.json`, com exatamente estas chaves:
{
 "id": "S01",
 "autores": "Sobrenome, I.; Sobrenome, I. (até 3, depois 'et al.')",
 "ano": 2022,
 "titulo": "...",
 "veiculo": "nome do periódico/conferência",
 "tipo_veiculo": "periódico | conferência | outro",
 "doi": "10.xxxx ou ''",
 "tipo_estudo": "RSL/survey | SoK | framework/modelo proposto | estudo empírico | estudo de caso | análise jurídico-normativa | lições aprendidas",
 "dominio": "geral | saúde | RH | educação | IA generativa | nuvem | outro (especifique)",
 "regulacoes": ["GDPR", "LGPD", "AI Act", "HIPAA", "ISO/IEC 27701", ...],
 "modelo_processo": "modelo de processo/ciclo de vida usado ou proposto e suas fases, conforme o artigo (ex.: 'ciclo próprio de 6 fases: ...', 'CRISP-DM', 'MLOps', 'nenhum')",
 "qp1_sintese": "2-4 frases: como o estudo integra privacidade ao processo/ciclo",
 "atividades": [
   {"atividade": "descrição curta", "fase": "F1..F6|TRANSV", "criterio_verificacao": "critério/métrica/limiar explícito, ou 'não especificado'", "artefato": "artefato/evidência produzida, ou 'não especificado'", "pagina": "p. X"}
 ],
 "pets": ["privacidade diferencial", "anonimização", "k-anonimato", "aprendizado federado", "criptografia homomórfica", "SMPC", "dados sintéticos", "TEE", ...],
 "qp3_lacunas": ["lacuna entre norma e engenharia apontada pelo estudo (com página)"],
 "qp4_mecanismos": {
   "tarefas": ["..."],
   "criterios_aceitacao": ["... (só os que têm critério verificável)"],
   "artefatos": ["..."],
   "base_risco": "sim | parcial | não — e como o risco é avaliado (ex.: DPIA, matriz probabilidade×impacto, ISO 27005, NIST)"
 },
 "avaliacao_proposta": "nenhuma | exemplo ilustrativo | estudo de caso | experimento | avaliação por especialistas | outro — descreva",
 "limitacoes": "limitações declaradas ou evidentes, 1-2 frases",
 "qa": {"QA1": 1, "QA2": 0.5, "QA3": 0, "QA4": 1, "QA5": 1, "total": 3.5,
        "justificativas": {"QA1": "...", "QA2": "...", "QA3": "...", "QA4": "...", "QA5": "..."}},
 "contribuicao_fgp_ia": "1-2 frases: o que este estudo oferece de aproveitável para a extensão do CRISP-ML(Q)"
}

Regras: escreva em português; seja fiel ao texto (não invente atividades, critérios ou números); indique página quando possível; se algo não existir no artigo, diga "não especificado". JSON válido (UTF-8), sem comentários.
