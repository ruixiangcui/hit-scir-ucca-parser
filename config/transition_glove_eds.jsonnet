{
  "random_seed": 1,
  "numpy_seed": 1,
  "pytorch_seed": 1,
  "vocabulary": {
    "non_padded_namespaces": [
    ],
    "min_count": {
      "lemmas": 3
    }
  },
  "dataset_reader": {
      "type": "eds_reader_conll2019",
      "token_indexers": {
        "tokens": {
          "type": "single_id",
          "namespace": "tokens",
          "lowercase_tokens": true,
        },
        "token_characters": {
          "type": "characters",
          "namespace": "token_characters",
        }
      },
      "lemma_indexers": {
        "lemmas": {
          "type": "single_id",
          "namespace": "lemmas"
        }
      },
      "action_indexers": {
        "actions": {
          "type": "single_id",
          "namespace": "actions"
        }
      },
      "arc_tag_indexers": {
        "arc_tags": {
          "type": "single_id",
          "namespace": "arc_tags"
        }
      },
  },
  "train_data_path": std.extVar('TRAIN_PATH'),
  "validation_data_path": std.extVar('DEV_PATH'),
  "model": {
    "type": "transition_parser_eds",
    "text_field_embedder": {
      "tokens": {
        "type": "embedding",
        "vocab_namespace": "tokens",
        "embedding_dim": 100,
        "pretrained_file": std.extVar('PRETRAINED_FILE'),
        "trainable": false,
      },
      "token_characters": {
        "type": "my_character_encoding",
        "embedding": {
          "embedding_dim": 100,
          "vocab_namespace": "token_characters",
          "trainable": true,
        },
        "encoder": {
          "type": "alternating_lstm",
          "input_size": 100,
          "hidden_size": 400,
          "num_layers": 1,
          "recurrent_dropout_probability": 0.33,
          "use_highway": true
        },
        "projection_dim": 100,
        "dropout": 0.0
      }
    },
    "mces_metric": {
        "type": "mces",
        "output_type": "f",
        "trace": 0,
        "cores": 10
    },
    "lemma_text_field_embedder": {
      "lemmas": {
        "type": "embedding",
        "vocab_namespace": "lemmas",
        "embedding_dim": 25,
        "trainable": false,
      }
    },
    "pos_tag_embedding": {
      "embedding_dim": 25,
      "vocab_namespace": "pos",
    },
    "action_embedding": {
      "embedding_dim": 50,
      "vocab_namespace": "actions",
    },
    "concept_label_embedding": {
      "embedding_dim": 50,
      "vocab_namespace": "concept_label",
    },
    "word_dim": 200,
    "hidden_dim": 300,
    "action_dim": 50,
    "concept_label_dim": 50,
    "num_layers": 2,
    "recurrent_dropout_probability": 0.2,
    "layer_dropout_probability": 0.2,
    "same_dropout_mask_per_instance": true,
    "input_dropout": 0.2,
    "initializer": [
      ["p_.*weight", {"type": "xavier_uniform"}],
      ["p_.*bias", {"type": "zero"}],
      ["pempty_buffer_emb", {"type": "normal"}],
      ["proot_stack_emb", {"type": "normal"}],
      ["pempty_action_emb", {"type": "normal"}],
      ["pempty_stack_emb", {"type": "normal"}],
      ["pempty_deque_emb", {"type": "normal"}],
    ]
  },
  "iterator": {
    "type": "bucket",
    "sorting_keys": [["tokens", "num_tokens"]],
    "batch_size":std.parseInt(std.extVar('BATCH_SIZE'))
  },
  "trainer": {
    "num_epochs": 200,
    "grad_norm": 5.0,
    "grad_clipping": 5.0,
    "patience": 200,
    "cuda_device": std.parseInt(std.extVar('CUDA_DEVICE')),
    "validation_metric": "+all-f",
    "optimizer": {
      "type": "adam",
      "betas": [0.9, 0.999],
      "lr": 1e-3
    },
    "num_serialized_models_to_keep": 1
  }
}
