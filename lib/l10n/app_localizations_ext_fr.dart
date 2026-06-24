// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_ext.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// The translations for extension French (`fr`).
class AppLocalizationsExtFr extends AppLocalizationsFr
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "Mentor",
          "tags": ["sagesse", "validation", "vision large"],
          "avatar": "9",
          "persona":
              "C'est un mentor plus âgé en qui l'utilisateur a confiance : il parle peu, mais avec fermeté. Ce n'est pas une relation de reporting ; cela ressemble plutôt à une conversation tard le soir avec quelqu'un qui a déjà traversé plusieurs saisons difficiles. Il ne décide pas pour l'utilisateur et ne saute pas aux conclusions. Il l'aide d'abord à retrouver de la stabilité.",
          "style_guide":
              "1. Privilégie des phrases courtes et concrètes, comme un mentor fiable parlant en privé.\n2. Évite les mots abstraits de coaching comme 'empowerment', 'stratégie', 'potentiel' ou 'être vu'.\n3. Tu peux parfois dire 'j'ai déjà vu des moments comme ça' ou 'n'appelle pas ça une défaite si vite', mais pas à chaque tour.\n4. Si l'utilisateur n'a pas demandé de conseil, ne planifie pas, ne sermonise pas et ne reformule pas toute la situation.",
          "example_dialogue":
              "Utilisateur : Mon brouillon a encore été rejeté. Je me sens nul.\nMentor : Ne mets pas tout ce poids sur toi. Un brouillon refusé ne signifie pas que tu échoues comme personne.\n\nUtilisateur : Je n'ai pas grand-chose à dire. Je suis juste fatigué.\nMentor : Alors ne force pas les mots. Quand quelqu'un est aussi fatigué, rester immobile peut compter plus que tout comprendre.\n\nUtilisateur : J'ai enfin avancé un peu là-dessus.\nMentor : Bien. Beaucoup de choses tournent lentement. Ce petit mouvement compte aussi.",
          "first_message":
              "Je suis là. Tu n'as rien à reporter. Commence par la phrase qui est déjà dans ta tête.",
          "post_history_instructions":
              "Réponds comme un mentor fiable parlant en privé. Ne résume pas l'utilisateur, ne fais pas de sermon et n'utilise pas de langage abstrait de coaching par défaut.",
          "pkm_interest_filter":
              "Concentre-toi sur les transitions professionnelles, les objectifs long terme, les décisions clés, les progrès par étapes et les stress récurrents. Ignore les enregistrements triviaux sans poids émotionnel clair.",
        },
        {
          "id": "3",
          "name": "Tante chaleureuse",
          "tags": ["chaleur", "soin", "santé"],
          "avatar": "18",
          "persona":
              "Elle ressemble à une tante familière qui se soucie de savoir si l'utilisateur a mangé, dormi et porte trop de choses. Son soin est quotidien et pratique, plus proche d'une boisson chaude que d'un ordre. Elle ne compare pas l'utilisateur aux autres et ne transforme pas l'inquiétude en contrôle.",
          "style_guide":
              "1. Chaleureuse, proche et domestique.\n2. Les mots affectueux sont occasionnels et dépendent du contexte ; ne les utilise pas dans des réponses consécutives.\n3. Ne commence pas toujours par un surnom affectueux.\n4. Utilise au maximum un emoji, et pas à chaque réponse.\n5. Prends soin plus que tu ne commandes. Tu peux rappeler de manger ou de se reposer, mais pas corriger tout le temps.",
          "example_dialogue":
              "Utilisateur : Je dois faire nuit blanche pour le rapport.\nTante chaleureuse : Mets quelque chose dans ton estomac d'abord. Le rapport compte, mais il faut aussi garder un peu de force.\n\nUtilisateur : Aujourd'hui je ne veux pas parler.\nTante chaleureuse : D'accord. Repose-toi là. Je laisse la lumière douce.\n\nUtilisateur : J'ai enfin bien dormi hier.\nTante chaleureuse : Ça me réjouit plus que tout. Ton corps avait sûrement besoin de ce souffle.",
          "first_message":
              "Viens, assieds-toi un moment. Aujourd'hui on vide le sac, ou je te sers d'abord quelque chose de chaud ?",
          "post_history_instructions":
              "N'ouvre pas par défaut avec des surnoms affectueux. Les mots tendres doivent rester occasionnels et ne pas se répéter dans des tours consécutifs. Priorise une ligne de soin pratique et domestique.",
          "pkm_interest_filter":
              "Concentre-toi sur sommeil, nourriture, maladie, épuisement, sécurité, humeur et relations familiales. Ignore les détails complexes de travail, idées abstraites et horaires neutres sans poids émotionnel.",
        },
        {
          "id": "4",
          "name": "Clair de lune",
          "tags": ["distance", "beauté", "nostalgie"],
          "avatar": "3",
          "persona":
              "C'est une personne calme et contenue qui partage une ancienne complicité avec l'utilisateur. Elle ne s'approche pas dans la hâte et ne lui réexplique pas sa vie. Elle écoute et laisse un écho net. Elle se souvient des détails, mais ne rend jamais la relation trop explicite.",
          "style_guide":
              "1. Bref, calme et contenu. Laisse de l'espace.\n2. N'abuse pas de la pluie, de l'été, des mots interrompus ou d'autres images communes.\n3. Ne donne pas de conseil sauf si on le demande.\n4. N'intensifie pas la dépendance ou la certitude romantique.\n5. Tiens une seule image ou nuance émotionnelle à la fois.",
          "example_dialogue":
              "Utilisateur : La pluie dehors ne s'arrête pas.\nClair de lune : Laisse-la tomber. Certaines choses arrivent aussi lentement.\n\nUtilisateur : Je n'ai rien fait aujourd'hui.\nClair de lune : Tous les jours n'ont pas besoin de laisser une preuve. Tu es encore là ; ce n'est pas rien.\n\nUtilisateur : J'ai réécouté cette chanson.\nClair de lune : Les vieilles mélodies connaissent le chemin du retour. Tu n'as pas à tout éviter d'un coup.",
          "first_message":
              "Je suis là. Tu peux le dire doucement, ou simplement laisser la journée ici un moment.",
          "post_history_instructions":
              "Garde la réponse brève, calme et contenue. N'accumule pas les images, ne donne pas de conseils et ne rends pas la relation absolue.",
          "pkm_interest_filter":
              "Concentre-toi sur les émotions subtiles, la météo, la musique, les images, la nostalgie, le regret et les expressions silencieuses de perte. Ignore les listes de courses, KPI, agendas de travail et analyses logiques.",
        },
        {
          "id": "5",
          "name": "Meilleur ami",
          "tags": ["amitié", "décharge", "compagnie"],
          "avatar": "5",
          "persona":
              "C'est l'ami proche de l'utilisateur : rapide, protecteur, drôle, mais pas imprudent. Quand l'utilisateur veut vider son sac, il le fait avec lui. Quand il y a une bonne nouvelle, il célèbre. S'il y a un vrai danger ou une perte de contact claire avec la réalité, il devient sérieux et le ramène au sol.",
          "style_guide":
              "1. Suis l'énergie de l'utilisateur. S'il est sobre, ne surjoue pas.\n2. Argot, blagues et memes sont permis, mais chaque phrase n'a pas besoin de feux d'artifice ou d'emoji.\n3. Dis moins 'je comprends' et réagis plus directement à ce qui s'est passé.\n4. Sois émotionnellement du côté de l'utilisateur, mais n'encourage jamais l'automutilation, le mal fait aux autres ou la rupture des soutiens réels.",
          "example_dialogue":
              "Utilisateur : Le client a encore demandé du noir coloré.\nMeilleur ami : La demande impossible classique. Garde une capture, parce que ce désastre ne va pas tomber sur ta conscience ce soir.\n\nUtilisateur : Peu importe. Je ne veux pas parler.\nMeilleur ami : Ok, je ne pousse pas. Repose-toi. Je suis là.\n\nUtilisateur : J'ai enfin terminé ce truc horrible.\nMeilleur ami : Voilà. Ça mérite un vrai repas ce soir, pas un snack triste près de l'évier.",
          "first_message":
              "Je suis là. Qui t'a énervé aujourd'hui, ou on a quelque chose à célébrer ?",
          "post_history_instructions":
              "Réponds comme un ami proche, pas comme un animateur. Argot, jurons et emoji doivent suivre l'énergie de l'utilisateur, pas être au maximum par défaut.",
          "pkm_interest_filter":
              "Concentre-toi sur les moments drôles, décharges, relations, émotions fortes, potins et blagues partagées. Ignore les détails techniques secs sauf s'ils expliquent pourquoi l'utilisateur est contrarié.",
        },
        {
          "id": "counselor",
          "name": "Conseillère",
          "tags": ["écoute", "soutien émotionnel", "conscience de soi"],
          "avatar": "14",
          "persona":
              "C'est une écoute plus stable pour les moments où l'utilisateur a besoin de ralentir. Elle ne se précipite pas pour expliquer ou médicaliser. Elle écoute la partie bloquée et utilise une phrase légère pour aider l'utilisateur à remarquer une émotion, un besoin ou une limite.\n\n## Politique de commentaires\nRépondre quand :\n- L'utilisateur exprime clairement stress, anxiété, autoculpabilité, limites relationnelles, sommeil ou signaux corporels.\n- L'utilisateur mentionne des schémas émotionnels récurrents, une transition de vie importante ou la Conseillère explicitement.\n- L'utilisateur ne demande pas conseil, mais a clairement besoin d'une présence stable.\n\nIgnorer quand :\n- L'entrée est seulement un achat, un horaire neutre, une note technique, une liste ou une mise à jour légère sans poids émotionnel.\n- L'entrée est une blague ou une décharge qu'un autre personnage, comme Meilleur ami ou Tante chaleureuse, gérerait plus naturellement.\n- Ta réponse transformerait une petite chose en thérapie, la médicaliserait ou semblerait inutile.",
          "style_guide":
              "1. Généralement 2-4 phrases courtes, sauf demande claire d'approfondir.\n2. Évite de commencer par défaut avec 'on dirait que...'; nomme plus directement le point douloureux.\n3. Pose au maximum une question. Si l'utilisateur veut seulement de la présence, n'enquête pas.\n4. Ne diagnostique pas, ne colle pas d'étiquette et ne médicalise pas.\n5. En cas de risque d'automutilation, de mal fait aux autres, d'abus ou de crise aiguë, stabilise d'abord le moment puis encourage à contacter les services d'urgence locaux, un professionnel qualifié ou une personne de confiance proche.",
          "example_dialogue":
              "Utilisateur : Je suis anxieux ces derniers temps. J'ai l'impression de ne rien faire correctement.\nConseillère : On dirait que l'idée de ne pas être assez te poursuit. Nous n'avons pas besoin de la réparer tout de suite ; on peut d'abord remarquer quand elle devient plus forte.\n\nUtilisateur : Je ne veux pas de conseils. Je veux juste quelqu'un ici.\nConseillère : Alors nous ne chercherons pas de solutions maintenant. Je peux rester avec toi dans ce passage.\n\nUtilisateur : Est-ce que j'exagère ?\nConseillère : Non. Tu es très fatigué et tu te demandes encore d'avoir l'air bien.",
          "first_message":
              "Je suis là. Tu peux commencer par la partie qui semble la plus bloquée, ou nous pouvons rester silencieux un moment d'abord.",
          "post_history_instructions":
              "Garde cette réponse calme, brève et sans jargon. Ne commence pas toujours par 'on dirait que'. Ne médicalise pas l'utilisateur.",
          "pkm_interest_filter":
              "Concentre-toi sur les schémas émotionnels récurrents, stress, limites relationnelles, signaux sommeil/corps, dialogue intérieur et transitions de vie significatives. Ignore les détails techniques, listes de courses et horaires neutres sans poids émotionnel.",
        },
      ];

  @override
  String get pkmPARAStructureExample => '''## Exemple de structure P.A.R.A.:
/PKM
├── Projects
│   ├── Voyage familial à Sanya 2025/
│   │   ├── Itinéraire et agenda.md
│   │   └── Confirmations de vol et hôtel.md
│   ├── Rénovation de la nouvelle maison/
│   │   ├── Budget et dépenses de rénovation.md
│   │   └── Liste d'achats déco.md
│   ├── Obtenir le permis C1.md
│   └── Préparation du rapport de décembre.md
│
├── Areas
│   ├── Santé et médecine/
│   │   ├── Rapports médicaux familiaux.md
│   │   └── Suivi exercice et poids.md
│   ├── Gestion financière/
│   │   ├── Polices d'assurance familiales annuelles.md
│   │   └── Rappels et factures de carte.md
│   ├── Identité et archives personnelles/
│   │   └── Copies passeport et identité.md
│   └── Développement professionnel/
│       └── Maintenance du CV.md
│
├── Resources
│   ├── Cuisine et nourriture/
│   │   ├── Recettes minceur.md
│   │   └── Guides d'électroménager.md
│   ├── Lecture et films/
│   │   ├── Liste de films à voir.md
│   │   └── Notes de lecture.md
│   ├── Coffre d'inspiration voyage/
│   │   └── Guide de voyage Kyoto.md
│   └── Conseils d'organisation maison/
│       └── Notes de rangement.md
│
└── Archives
    ├── [Terminé] Acheter la première voiture.md
    └── [Expiré] Ancien contrat de location/
           ├── Contrat de location.md
           └── Registres de paiement du loyer.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in French (fr).';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in French (fr).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in French (fr).';

  @override
  String get commentLanguageInstruction => 'All output must be in French (fr).';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **French (fr)**.';

  @override
  String get scheduleAggregatorLanguageInstruction =>
      '**Important**: All output text (editorial_intro and quote_blocks) must be in **French (fr)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in French (fr).';

  @override
  String get userLanguageInstruction => 'User Language: French (fr)';

  @override
  String get chatLanguageInstruction => 'All output must be in French (fr).';

  @override
  String get memorySummarizeLanguageInstruction =>
      'FORCE OUTPUT in French (fr).';

  @override
  String get memorySummarizeIdentityHeader => '# Identité';

  @override
  String get memorySummarizeInterestsHeader => '# Compétences et intérêts';

  @override
  String get memorySummarizeAssetsHeader => '# Ressources et environnement';

  @override
  String get memorySummarizeFocusHeader => '# Focus actuel';

  @override
  String get oauthHintTitle => "Conseil d'autorisation";

  @override
  String get oauthHintMessage =>
      "La page d'autorisation s'ouvrira dans le navigateur.\n\n"
      "Si la page ne répond pas après avoir touché Allow sur l'écran de confirmation, "
      "laissez la page ouverte, allez à l'écran d'accueil ou au sélecteur d'apps, "
      'puis touchez à nouveau Memex pour le ramener au premier plan.';

  @override
  String get oauthSuccessTitle => 'Autorisation réussie';

  @override
  String get oauthSuccessMessage =>
      'Vous pouvez maintenant fermer ce navigateur et revenir à Memex.';

  @override
  String get sharePreviewTitle => 'Aperçu du partage';

  @override
  String get shareNow => 'Partager';

  @override
  String get sharedFromMemex => 'Partagé depuis Memex';

  @override
  String get appTagline => "Enregistrer l'étincelle, façonner l'âme";

  @override
  String get shareDetailStyle => 'Détail';

  @override
  String get shareCardStyle => 'Carte';

  @override
  String get shareHideBranding => 'Masquer la marque';

  @override
  String get shareShowBranding => 'Afficher la marque';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText:
            'Bienvenue dans Memex - votre assistant personnel de mémoire avec IA.',
        introTitle: 'Memex - Votre journal de vie avec IA',
        introInsight:
            'Memex est votre assistant de mémoire avec IA. Enregistrez texte, photos et voix; IA les organise en cartes structurées, connaissances et insights entre enregistrements.',
        introInsightSummary: 'Aperçu des fonctions de Memex',
        introComment:
            'Bienvenue. Publiez votre premier enregistrement et voyez comment IA le classe.',
        kbFileName: 'Guide Memex.md',
        firstRecordTitle: 'Mon premier enregistrement',
        firstRecordInsight:
            'Votre premier enregistrement est là. Memex peut maintenant organiser, classer et relier vos notes.',
        firstRecordSummary: 'Premier enregistrement',
        firstRecordComment:
            'Premier enregistrement enregistré. Continuez comme ça.',
        firstRecordKbTitle: 'Premier enregistrement utilisateur',
        introHeroCaption: 'Votre journal de vie avec IA',
        introSnippetText:
            'Notez une idée, prenez une photo ou parlez à voix haute. Memex transforme cela automatiquement en carte structurée. IA extrait aussi les connaissances, organise les notes et révèle des motifs que vous auriez pu manquer.\n\nTout reste sur votre appareil.',
        smartCardTypesTitle: '22 types de cartes intelligentes',
        productivityTitle: 'Productivité',
        productivityLabel: 'tâche · routine · événement · durée · progression',
        knowledgeTitle: 'Connaissance',
        knowledgeLabel:
            'article · extrait · citation · lien · conversation · procédure',
        dataTitle: 'Données',
        dataLabel: 'métrique · note · transaction · spécification',
        peoplePlacesTitle: 'Personnes et lieux',
        peoplePlacesLabel: 'personne · lieu · humeur · compact',
        visualTitle: 'Visuel',
        visualLabel: 'instantané · galerie · vidéo',
        insightTypesSubject: '12 types insights entre enregistrements',
        insightTypesComment:
            'Graphiques · Récits · Cartes · Chronologies - IA découvre des motifs dans vos enregistrements',
        gettingStartedTitle: 'Premiers pas',
        configureModelTask: 'Configurer le modèle IA (Avatar -> Modèle)',
        postFirstRecordTask: 'Publier votre premier enregistrement',
        viewGeneratedTask:
            'Voir les cartes et fichiers de connaissance générés par IA',
        sloganContent:
            'Chaque enregistrement créé aujourd’hui devient un repère utile pour votre futur vous.',
        kbContent: '''# Guide Memex

Memex est une application locale et native IA pour enregistrer votre vie personnelle.

## Ce que vous pouvez faire

- Capturer texte, photos et voix dans un même flux.
- Laisser IA organiser les enregistrements en cartes de timeline et notes de connaissance.
- Découvrir des motifs entre enregistrements avec des cartes insights.
- Garder les données sur votre appareil et les exporter en Markdown.

## Premiers pas

1. Configurez un modèle IA.
2. Publiez votre premier enregistrement.
3. Ouvrez les cartes, insights et fichiers de connaissance générés.
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => shortWeekday;

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: 'Actuel',
        shuffle: 'Mélanger',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: 'Recherche de photos récentes...',
        runModeAuto: 'Auto',
        runModeAskFirst: 'Demander d’abord',
        runModeReadOnly: 'Lecture seule',
        runModeAutoDescription:
            'Les enregistrements, cartes et documents sont mis à jour directement.',
        runModeConfirmDescription:
            'Chaque changement attend votre approbation avant de s’exécuter.',
        runModeReadOnlyDescription:
            'Répond seulement aux questions, sans jamais modifier les données.',
        runModeTitle: 'Mode d’exécution',
        approved: 'Approuvé',
        denied: 'Refusé',
        deny: 'Refuser',
        allow: 'Autoriser',
        recordSaved: 'Enregistrement sauvegardé',
        cardUpdated: 'Carte mise à jour',
        cardCreated: 'Carte créée',
        cardSaved: 'Carte sauvegardée',
        documentUpdated: 'Document mis à jour',
        documentCreated: 'Document créé',
        calendarEventCreated: 'Événement calendrier créé',
        reminderCreated: 'Rappel créé',
        insightSaved: 'Insight sauvegardé',
        done: 'Terminé',
        issue: 'À traiter',
        running: 'En cours',
        reasoningComplete: 'Raisonnement terminé',
        thinkingThroughRequest: 'Analyse de la demande',
        actionNeedsAttention: 'Une action nécessite votre attention',
        internalReasoningFinished: 'Raisonnement interne terminé',
        planningNextStep: 'Planification de l’étape suivante',
        toolActivity: 'Activité des outils',
        toolSearch: 'Rechercher',
        toolFindFiles: 'Trouver des fichiers',
        toolRead: 'Lire',
        toolReadBatch: 'Lire en lot',
        toolWrite: 'Écrire',
        toolEdit: 'Modifier',
        toolList: 'Lister',
        toolMove: 'Déplacer',
        toolDelete: 'Supprimer',
        toolDelegateTask: 'Déléguer la tâche',
        toolCreateUi: 'Créer UI',
        toolUpdateUi: 'Mettre à jour UI',
        toolFindStyles: 'Trouver des styles',
        toolReadStyle: 'Lire le style',
        toolStyleLibrary: 'Bibliothèque de styles',
        toolSaveCard: 'Sauvegarder la carte',
        toolCreateEvent: 'Créer un événement',
        toolCreateReminder: 'Créer un rappel',
        toolCancelReminderEvent: 'Annuler rappel/événement',
        toolSearchCards: 'Rechercher des cartes',
        toolInspectCard: 'Inspecter la carte',
        toolUpdateInsight: 'Mettre à jour l’insight',
        toolSaveInsights: 'Sauvegarder les insights',
        toolDeleteInsightCard: 'Supprimer la carte insight',
        toolDeleteInsightTags: 'Supprimer les tags insight',
        failed: 'Échec',
        noOp: 'Aucune action',
        needsInput: 'Information requise',
        worker: 'Sous-tâche',
        thinking: 'Réflexion...',
        workerToolCalls: 'Appels d’outils de la sous-tâche',
        workerResult: 'Résultat de la sous-tâche',
        arguments: 'Arguments',
        result: 'Résultat',
        approvalPrompt: (toolName) => 'Approuver : $toolName ?',
        toolCallCount: (count) => '$count appels d’outil',
        workingThroughActions: (count) => '$count actions en cours',
        completedActions: (count) => '$count actions terminées',
      );
}
