---
title: AI-Basic
date: 2025-07-29 13:45:26
tags: 
- 原创
categories: 
- AI
---

**阅读更多**

<!--more-->

# 1 Evolution History

1. [Attention Is All You Need](/resources/paper/Attention-Is-All-You-Need.pdf)
1. [BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding](/resources/paper/BERT-Pre-training-of-Deep-Bidirectional-Transformers-for-Language-Understanding.pdf)
1. [Improving Language Understanding by Generative Pre-Training](/resources/paper/Improving-Language-Understanding-by-Generative-Pre-Training.pdf)
1. [Language Models are Unsupervised Multitask Learners](/resources/paper/Language-Models-are-Unsupervised-Multitask-Learners.pdf)
1. [Scaling Laws for Neural Language Models](/resources/paper/Scaling-Laws-for-Neural-Language-Models.pdf)
1. [Language Models are Few-Shot Learners](/resources/paper/Language-Models-are-Few-Shot-Learners.pdf)
1. [On the Opportunities and Risks of Foundation Models]()
1. [Training language models to follow instructions with human feedback](/resources/paper/Training-language-models-to-follow-instructions-with-human-feedback.pdf)
1. [Chain-of-Thought Prompting Elicits Reasoning in Large Language Models](/resources/paper/Chain-of-Thought-Prompting-Elicits-Reasoning-in-Large-Language-Models.pdf)
1. [Self-Consistency Improves Chain of Thought Reasoning in Language Models](/resources/paper/SELF-CONSISTENCY-IMPROVES-CHAIN-OF-THOUGHT-REASONING-IN-LANGUAGE-MODELS.pdf)
1. [LLaMA: Open and Efficient Foundation Language Models](/resources/paper/LLaMA-Open-and-Efficient-Foundation-Language-Models.pdf)
1. [Alpaca: A Strong, Replicable Instruction-Following Model]()
1. [Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks](/resources/paper/Retrieval-Augmented-Generation-for-Knowledge-Intensive-NLP-Tasks.pdf)
1. [Toolformer: Language Models Can Teach Themselves to Use Tools](/resources/paper/Toolformer-Language-Models-Can-Teach-Themselves-to-Use-Tools.pdf)
1. [Learning Transferable Visual Models From Natural Language Supervision](/resources/paper/Learning-Transferable-Visual-Models-From-Natural-Language-Supervision.pdf)
1. [Direct Preference Optimization: Your Language Model is Secretly a Reward Model](/resources/paper/Direct-Preference-Optimization-Your-Language-Model-is-Secretly-a-Reward-Model.pdf)
1. [Switch Transformers: Scaling to Trillion Parameter Models with Simple and Efficient Sparsity]()

# 2 Terminology

## 2.1 Encoder & Decoder

Encoder and decoder refer to two different ways a Transformer model processes language.

* Encoder models focus on understanding input by reading the entire sequence bidirectionally and producing rich contextual representations.
* Decoder models focus on generating output by predicting tokens sequentially in an autoregressive manner.
* Encoder–decoder models combine both: the encoder first processes the input, and the decoder then generates output conditioned on that representation.

Modern large language models (LLMs), such as GPT-style systems, are typically **decoder-only**, because autoregressive generation can flexibly support a wide range of tasks (e.g., QA, translation, coding) through prompting without task-specific fine-tuning.

| Architecture | Core Function | Context Access | Training Objective | Strengths | Weaknesses | Representative Models |
|:--|:--|:--|:--|:--|:--|:--|
| Encoder | Understanding | Bidirectional (full input) | Masked token prediction (MLM) | Strong semantic representation | Not suitable for text generation | BERT |
| Decoder | Generation | Unidirectional (left-only) | Next-token prediction (autoregressive) | Flexible generation, general-purpose | Weaker explicit bidirectional understanding | GPT series |
| Encoder–Decoder | Seq2Seq (hybrid) | Encoder: bidirectional; Decoder: left-only | Conditional generation (input → output) | Best for structured tasks (translation, summarization) | More complex, less flexible than decoder-only | T5, BART |

# 3 Agent

## 3.1 [claude-code](https://github.com/anthropics/claude-code)

## 3.2 [codex](https://github.com/openai/codex)

**Example:**

* `codex --ask-for-approval never --sandbox danger-full-access "<prompt>"`
* `codex --ask-for-approval never --sandbox danger-full-access resume`

## 3.3 [trae-agent](https://github.com/bytedance/trae-agent)

## 3.4 Models

* OpenAI: GPT
* Google DeepMind: Gemini
* Anthropic: Claude
* DeepSeek
* Qwen
