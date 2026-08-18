export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.15"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      beta_reset_audit: {
        Row: {
          after_counts: Json
          before_counts: Json
          confirmation_phrase: string
          database_session: string
          executed_at: string
          executed_by: string | null
          id: string
        }
        Insert: {
          after_counts: Json
          before_counts: Json
          confirmation_phrase: string
          database_session: string
          executed_at?: string
          executed_by?: string | null
          id?: string
        }
        Update: {
          after_counts?: Json
          before_counts?: Json
          confirmation_phrase?: string
          database_session?: string
          executed_at?: string
          executed_by?: string | null
          id?: string
        }
        Relationships: []
      }
      regional_fantasy_lineups: {
        Row: { id:string; user_id:string; week_id:string; captain_player_id:string|null; status:string; submitted_at:string|null; locked_at:string|null; created_at:string; updated_at:string }
        Insert: { id?:string; user_id:string; week_id:string; captain_player_id?:string|null; status?:string; submitted_at?:string|null; locked_at?:string|null; created_at?:string; updated_at?:string }
        Update: { id?:string; user_id?:string; week_id?:string; captain_player_id?:string|null; status?:string; submitted_at?:string|null; locked_at?:string|null; created_at?:string; updated_at?:string }
        Relationships: []
      }
      regional_fantasy_lineup_players: {
        Row: { id:string; lineup_id:string; player_id:string; team_id:string; slot_role:string; created_at:string }
        Insert: { id?:string; lineup_id:string; player_id:string; team_id:string; slot_role:string; created_at?:string }
        Update: { id?:string; lineup_id?:string; player_id?:string; team_id?:string; slot_role?:string; created_at?:string }
        Relationships: []
      }
      competition_weeks: {
        Row: {
          created_at: string
          ends_at: string
          finalized_at: string | null
          id: string
          meta_locks_at: string
          mvp_locks_at: string
          name: string
          season_id: string
          starts_at: string
          updated_at: string
          week_number: number
        }
        Insert: {
          created_at?: string
          ends_at: string
          finalized_at?: string | null
          id?: string
          meta_locks_at: string
          mvp_locks_at: string
          name: string
          season_id: string
          starts_at: string
          updated_at?: string
          week_number: number
        }
        Update: {
          created_at?: string
          ends_at?: string
          finalized_at?: string | null
          id?: string
          meta_locks_at?: string
          mvp_locks_at?: string
          name?: string
          season_id?: string
          starts_at?: string
          updated_at?: string
          week_number?: number
        }
        Relationships: [
          {
            foreignKeyName: "competition_weeks_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
        ]
      }
      draft_picks: {
        Row: {
          auto_picked: boolean
          draft_id: string
          id: string
          league_id: string
          pick_number: number
          picked_at: string
          player_id: string
          round_number: number
          user_id: string
        }
        Insert: {
          auto_picked?: boolean
          draft_id: string
          id?: string
          league_id: string
          pick_number: number
          picked_at?: string
          player_id: string
          round_number: number
          user_id: string
        }
        Update: {
          auto_picked?: boolean
          draft_id?: string
          id?: string
          league_id?: string
          pick_number?: number
          picked_at?: string
          player_id?: string
          round_number?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "draft_picks_draft_id_fkey"
            columns: ["draft_id"]
            isOneToOne: false
            referencedRelation: "drafts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "draft_picks_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "draft_picks_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
        ]
      }
      drafts: {
        Row: {
          completed_at: string | null
          created_at: string
          current_pick_number: number
          id: string
          league_id: string
          manager_count: number | null
          roster_size: number
          scheduled_at: string | null
          started_at: string | null
          status: string
          turn_expires_at: string | null
          updated_at: string
        }
        Insert: {
          completed_at?: string | null
          created_at?: string
          current_pick_number?: number
          id?: string
          league_id: string
          manager_count?: number | null
          roster_size?: number
          scheduled_at?: string | null
          started_at?: string | null
          status?: string
          turn_expires_at?: string | null
          updated_at?: string
        }
        Update: {
          completed_at?: string | null
          created_at?: string
          current_pick_number?: number
          id?: string
          league_id?: string
          manager_count?: number | null
          roster_size?: number
          scheduled_at?: string | null
          started_at?: string | null
          status?: string
          turn_expires_at?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "drafts_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: true
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
        ]
      }
      fantasy_leagues: {
        Row: {
          chat_enabled: boolean
          commissioner_id: string
          constraints: Json
          created_at: string
          creator_profile_id: string | null
          description: string | null
          format: string
          id: string
          invite_code: string
          lineup_locks_at: string | null
          max_managers: number
          name: string
          pick_seconds: number
          salary_budget: number | null
          scoring_ends_at: string | null
          scoring_starts_at: string | null
          season_id: string
          status: string
          transfer_limit: number
          updated_at: string
          visibility: string
        }
        Insert: {
          chat_enabled?: boolean
          commissioner_id: string
          constraints?: Json
          created_at?: string
          creator_profile_id?: string | null
          description?: string | null
          format?: string
          id?: string
          invite_code?: string
          lineup_locks_at?: string | null
          max_managers?: number
          name: string
          pick_seconds?: number
          salary_budget?: number | null
          scoring_ends_at?: string | null
          scoring_starts_at?: string | null
          season_id: string
          status?: string
          transfer_limit?: number
          updated_at?: string
          visibility?: string
        }
        Update: {
          chat_enabled?: boolean
          commissioner_id?: string
          constraints?: Json
          created_at?: string
          creator_profile_id?: string | null
          description?: string | null
          format?: string
          id?: string
          invite_code?: string
          lineup_locks_at?: string | null
          max_managers?: number
          name?: string
          pick_seconds?: number
          salary_budget?: number | null
          scoring_ends_at?: string | null
          scoring_starts_at?: string | null
          season_id?: string
          status?: string
          transfer_limit?: number
          updated_at?: string
          visibility?: string
        }
        Relationships: [
          {
            foreignKeyName: "fantasy_leagues_creator_profile_id_fkey"
            columns: ["creator_profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fantasy_leagues_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
        ]
      }
      h2h_bans: {
        Row: {
          banned_player_id: string
          id: string
          matchup_id: string
          submitted_at: string
          submitted_by: string
          target_user_id: string
        }
        Insert: {
          banned_player_id: string
          id?: string
          matchup_id: string
          submitted_at?: string
          submitted_by: string
          target_user_id: string
        }
        Update: {
          banned_player_id?: string
          id?: string
          matchup_id?: string
          submitted_at?: string
          submitted_by?: string
          target_user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "h2h_bans_banned_player_id_fkey"
            columns: ["banned_player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "h2h_bans_matchup_id_fkey"
            columns: ["matchup_id"]
            isOneToOne: false
            referencedRelation: "h2h_matchups"
            referencedColumns: ["id"]
          },
        ]
      }
      h2h_matchups: {
        Row: {
          away_score: number | null
          away_user_id: string
          ban_locks_at: string
          bans_reveal_at: string
          created_at: string
          home_score: number | null
          home_user_id: string
          id: string
          league_id: string
          lineup_locks_at: string
          status: string
          week_id: string
          winner_user_id: string | null
        }
        Insert: {
          away_score?: number | null
          away_user_id: string
          ban_locks_at: string
          bans_reveal_at: string
          created_at?: string
          home_score?: number | null
          home_user_id: string
          id?: string
          league_id: string
          lineup_locks_at: string
          status?: string
          week_id: string
          winner_user_id?: string | null
        }
        Update: {
          away_score?: number | null
          away_user_id?: string
          ban_locks_at?: string
          bans_reveal_at?: string
          created_at?: string
          home_score?: number | null
          home_user_id?: string
          id?: string
          league_id?: string
          lineup_locks_at?: string
          status?: string
          week_id?: string
          winner_user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "h2h_matchups_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "h2h_matchups_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
      heroes: {
        Row: {
          active: boolean
          id: string
          name: string
          portrait_url: string | null
          source_url: string | null
          standard_roles: string[]
          updated_at: string
        }
        Insert: {
          active?: boolean
          id?: string
          name: string
          portrait_url?: string | null
          source_url?: string | null
          standard_roles?: string[]
          updated_at?: string
        }
        Update: {
          active?: boolean
          id?: string
          name?: string
          portrait_url?: string | null
          source_url?: string | null
          standard_roles?: string[]
          updated_at?: string
        }
        Relationships: []
      }
      league_chat_messages: {
        Row: {
          created_at: string
          id: string
          league_id: string
          message: string
          message_type: string
          moderated: boolean
          removed_at: string | null
          reply_to_id: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          league_id: string
          message: string
          message_type?: string
          moderated?: boolean
          removed_at?: string | null
          reply_to_id?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          league_id?: string
          message?: string
          message_type?: string
          moderated?: boolean
          removed_at?: string | null
          reply_to_id?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "league_chat_messages_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "league_chat_messages_reply_to_id_fkey"
            columns: ["reply_to_id"]
            isOneToOne: false
            referencedRelation: "league_chat_messages"
            referencedColumns: ["id"]
          },
        ]
      }
      league_chat_reactions: {
        Row: {
          created_at: string
          id: string
          message_id: string
          reaction: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          message_id: string
          reaction: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          message_id?: string
          reaction?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "league_chat_reactions_message_id_fkey"
            columns: ["message_id"]
            isOneToOne: false
            referencedRelation: "league_chat_messages"
            referencedColumns: ["id"]
          },
        ]
      }
      league_members: {
        Row: {
          draft_position: number | null
          eliminated_at: string | null
          id: string
          joined_at: string
          league_id: string
          member_role: string
          status: string
          user_id: string
          waiver_priority: number | null
        }
        Insert: {
          draft_position?: number | null
          eliminated_at?: string | null
          id?: string
          joined_at?: string
          league_id: string
          member_role?: string
          status?: string
          user_id: string
          waiver_priority?: number | null
        }
        Update: {
          draft_position?: number | null
          eliminated_at?: string | null
          id?: string
          joined_at?: string
          league_id?: string
          member_role?: string
          status?: string
          user_id?: string
          waiver_priority?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "league_members_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
        ]
      }
      league_moderation: {
        Row: {
          actioned_by: string
          created_at: string
          id: string
          league_id: string
          muted_until: string | null
          reason: string | null
          user_id: string
        }
        Insert: {
          actioned_by: string
          created_at?: string
          id?: string
          league_id: string
          muted_until?: string | null
          reason?: string | null
          user_id: string
        }
        Update: {
          actioned_by?: string
          created_at?: string
          id?: string
          league_id?: string
          muted_until?: string | null
          reason?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "league_moderation_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
        ]
      }
      lineup_players: {
        Row: {
          created_at: string
          id: string
          lineup_id: string
          player_id: string
          price_snapshot: number | null
          slot_role: string
          team_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          lineup_id: string
          player_id: string
          price_snapshot?: number | null
          slot_role: string
          team_id: string
        }
        Update: {
          created_at?: string
          id?: string
          lineup_id?: string
          player_id?: string
          price_snapshot?: number | null
          slot_role?: string
          team_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "lineup_players_lineup_id_fkey"
            columns: ["lineup_id"]
            isOneToOne: false
            referencedRelation: "weekly_lineups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lineup_players_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "lineup_players_team_id_fkey"
            columns: ["team_id"]
            isOneToOne: false
            referencedRelation: "teams"
            referencedColumns: ["id"]
          },
        ]
      }
      match_predictions: {
        Row: {
          id: string
          match_id: string
          predicted_away_score: number | null
          predicted_home_score: number | null
          predicted_winner_team_id: string
          submitted_at: string
          updated_at: string
          user_id: string
        }
        Insert: {
          id?: string
          match_id: string
          predicted_away_score?: number | null
          predicted_home_score?: number | null
          predicted_winner_team_id: string
          submitted_at?: string
          updated_at?: string
          user_id: string
        }
        Update: {
          id?: string
          match_id?: string
          predicted_away_score?: number | null
          predicted_home_score?: number | null
          predicted_winner_team_id?: string
          submitted_at?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "match_predictions_match_id_fkey"
            columns: ["match_id"]
            isOneToOne: false
            referencedRelation: "matches"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "match_predictions_predicted_winner_team_id_fkey"
            columns: ["predicted_winner_team_id"]
            isOneToOne: false
            referencedRelation: "teams"
            referencedColumns: ["id"]
          },
        ]
      }
      matches: {
        Row: {
          away_score: number | null
          away_team_id: string
          best_of: number
          created_at: string
          finalized_at: string | null
          external_provider: string | null
          external_match_id: number | null
          home_score: number | null
          home_team_id: string
          id: string
          prediction_locks_at: string
          result_state: string
          scheduled_at: string
          season_id: string
          source_url: string | null
          status: string
          updated_at: string
          week_id: string
          winner_team_id: string | null
        }
        Insert: {
          away_score?: number | null
          away_team_id: string
          best_of?: number
          created_at?: string
          finalized_at?: string | null
          external_provider?: string | null
          external_match_id?: number | null
          home_score?: number | null
          home_team_id: string
          id?: string
          prediction_locks_at: string
          result_state?: string
          scheduled_at: string
          season_id: string
          source_url?: string | null
          status?: string
          updated_at?: string
          week_id: string
          winner_team_id?: string | null
        }
        Update: {
          away_score?: number | null
          away_team_id?: string
          best_of?: number
          created_at?: string
          finalized_at?: string | null
          external_provider?: string | null
          external_match_id?: number | null
          home_score?: number | null
          home_team_id?: string
          id?: string
          prediction_locks_at?: string
          result_state?: string
          scheduled_at?: string
          season_id?: string
          source_url?: string | null
          status?: string
          updated_at?: string
          week_id?: string
          winner_team_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "matches_away_team_id_fkey"
            columns: ["away_team_id"]
            isOneToOne: false
            referencedRelation: "teams"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "matches_home_team_id_fkey"
            columns: ["home_team_id"]
            isOneToOne: false
            referencedRelation: "teams"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "matches_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "matches_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "matches_winner_team_id_fkey"
            columns: ["winner_team_id"]
            isOneToOne: false
            referencedRelation: "teams"
            referencedColumns: ["id"]
          },
        ]
      }
      meta_predictions: {
        Row: {
          buffed_hero_id: string | null
          expected_contest_increase: string | null
          flex_hero_id: string | null
          highest_ban_rate_range: string | null
          id: string
          most_banned_hero_id: string | null
          most_contested_hero_id: string | null
          most_picked_hero_id: string | null
          predicted_flex_role: string | null
          submitted_at: string | null
          updated_at: string
          user_id: string
          week_id: string
        }
        Insert: {
          buffed_hero_id?: string | null
          expected_contest_increase?: string | null
          flex_hero_id?: string | null
          highest_ban_rate_range?: string | null
          id?: string
          most_banned_hero_id?: string | null
          most_contested_hero_id?: string | null
          most_picked_hero_id?: string | null
          predicted_flex_role?: string | null
          submitted_at?: string | null
          updated_at?: string
          user_id: string
          week_id: string
        }
        Update: {
          buffed_hero_id?: string | null
          expected_contest_increase?: string | null
          flex_hero_id?: string | null
          highest_ban_rate_range?: string | null
          id?: string
          most_banned_hero_id?: string | null
          most_contested_hero_id?: string | null
          most_picked_hero_id?: string | null
          predicted_flex_role?: string | null
          submitted_at?: string | null
          updated_at?: string
          user_id?: string
          week_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "meta_predictions_buffed_hero_id_fkey"
            columns: ["buffed_hero_id"]
            isOneToOne: false
            referencedRelation: "heroes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "meta_predictions_flex_hero_id_fkey"
            columns: ["flex_hero_id"]
            isOneToOne: false
            referencedRelation: "heroes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "meta_predictions_most_banned_hero_id_fkey"
            columns: ["most_banned_hero_id"]
            isOneToOne: false
            referencedRelation: "heroes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "meta_predictions_most_contested_hero_id_fkey"
            columns: ["most_contested_hero_id"]
            isOneToOne: false
            referencedRelation: "heroes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "meta_predictions_most_picked_hero_id_fkey"
            columns: ["most_picked_hero_id"]
            isOneToOne: false
            referencedRelation: "heroes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "meta_predictions_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
      official_weekly_mvps: {
        Row: {
          finalized_at: string | null
          finalized_by: string | null
          player_id: string
          result_state: string
          source_url: string | null
          week_id: string
        }
        Insert: {
          finalized_at?: string | null
          finalized_by?: string | null
          player_id: string
          result_state?: string
          source_url?: string | null
          week_id: string
        }
        Update: {
          finalized_at?: string | null
          finalized_by?: string | null
          player_id?: string
          result_state?: string
          source_url?: string | null
          week_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "official_weekly_mvps_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "official_weekly_mvps_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: true
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
      patches: {
        Row: {
          active: boolean
          created_at: string
          id: string
          notes_url: string | null
          released_at: string | null
          version: string
        }
        Insert: {
          active?: boolean
          created_at?: string
          id?: string
          notes_url?: string | null
          released_at?: string | null
          version: string
        }
        Update: {
          active?: boolean
          created_at?: string
          id?: string
          notes_url?: string | null
          released_at?: string | null
          version?: string
        }
        Relationships: []
      }
      player_match_stats: {
        Row: {
          assists: number
          created_at: string
          entered_by: string | null
          id: string
          kills: number
          match_id: string
          player_id: string
          team_id: string
          updated_at: string
        }
        Insert: {
          assists?: number
          created_at?: string
          entered_by?: string | null
          id?: string
          kills?: number
          match_id: string
          player_id: string
          team_id: string
          updated_at?: string
        }
        Update: {
          assists?: number
          created_at?: string
          entered_by?: string | null
          id?: string
          kills?: number
          match_id?: string
          player_id?: string
          team_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "player_match_stats_match_id_fkey"
            columns: ["match_id"]
            isOneToOne: false
            referencedRelation: "matches"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "player_match_stats_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "player_match_stats_team_id_fkey"
            columns: ["team_id"]
            isOneToOne: false
            referencedRelation: "teams"
            referencedColumns: ["id"]
          },
        ]
      }
      player_ownership: {
        Row: {
          acquired_at: string
          acquired_via: string
          id: string
          league_id: string
          player_id: string
          released_at: string | null
          user_id: string
        }
        Insert: {
          acquired_at?: string
          acquired_via: string
          id?: string
          league_id: string
          player_id: string
          released_at?: string | null
          user_id: string
        }
        Update: {
          acquired_at?: string
          acquired_via?: string
          id?: string
          league_id?: string
          player_id?: string
          released_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "player_ownership_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "player_ownership_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
        ]
      }
      player_prices: {
        Row: {
          created_at: string
          id: string
          player_id: string
          price: number
          season_id: string
          week_id: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          player_id: string
          price: number
          season_id: string
          week_id?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          player_id?: string
          price?: number
          season_id?: string
          week_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "player_prices_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "player_prices_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "player_prices_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
      players: {
        Row: {
          active: boolean
          country_code: string | null
          created_at: string
          handle: string
          id: string
          legal_name: string | null
          photo_url: string | null
          source_url: string | null
          updated_at: string
          verified_at: string | null
        }
        Insert: {
          active?: boolean
          country_code?: string | null
          created_at?: string
          handle: string
          id?: string
          legal_name?: string | null
          photo_url?: string | null
          source_url?: string | null
          updated_at?: string
          verified_at?: string | null
        }
        Update: {
          active?: boolean
          country_code?: string | null
          created_at?: string
          handle?: string
          id?: string
          legal_name?: string | null
          photo_url?: string | null
          source_url?: string | null
          updated_at?: string
          verified_at?: string | null
        }
        Relationships: []
      }
      playoff_bracket_predictions: {
        Row: {
          bracket_version: number
          id: string
          locks_at: string
          picks: Json
          predicted_champion_team_id: string | null
          season_id: string
          submitted_at: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          bracket_version?: number
          id?: string
          locks_at: string
          picks?: Json
          predicted_champion_team_id?: string | null
          season_id: string
          submitted_at?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          bracket_version?: number
          id?: string
          locks_at?: string
          picks?: Json
          predicted_champion_team_id?: string | null
          season_id?: string
          submitted_at?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "playoff_bracket_predictions_predicted_champion_team_id_fkey"
            columns: ["predicted_champion_team_id"]
            isOneToOne: false
            referencedRelation: "teams"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "playoff_bracket_predictions_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_private: {
        Row: {
          address: string | null
          created_at: string
          date_of_birth: string | null
          full_name: string
          updated_at: string
          user_id: string
        }
        Insert: {
          address?: string | null
          created_at?: string
          date_of_birth?: string | null
          full_name: string
          updated_at?: string
          user_id: string
        }
        Update: {
          address?: string | null
          created_at?: string
          date_of_birth?: string | null
          full_name?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          account_role: string
          avatar_url: string | null
          bio: string | null
          country_code: string
          created_at: string
          creator_verified: boolean
          id: string
          manager_name: string
          updated_at: string
        }
        Insert: {
          account_role?: string
          avatar_url?: string | null
          bio?: string | null
          country_code?: string
          created_at?: string
          creator_verified?: boolean
          id: string
          manager_name: string
          updated_at?: string
        }
        Update: {
          account_role?: string
          avatar_url?: string | null
          bio?: string | null
          country_code?: string
          created_at?: string
          creator_verified?: boolean
          id?: string
          manager_name?: string
          updated_at?: string
        }
        Relationships: []
      }
      region_memberships: {
        Row: {
          id: string
          joined_at: string
          region_code: string
          user_id: string
        }
        Insert: {
          id?: string
          joined_at?: string
          region_code: string
          user_id: string
        }
        Update: {
          id?: string
          joined_at?: string
          region_code?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "region_memberships_region_code_fkey"
            columns: ["region_code"]
            isOneToOne: false
            referencedRelation: "regions"
            referencedColumns: ["code"]
          },
        ]
      }
      regions: {
        Row: {
          active: boolean
          code: string
          created_at: string
          name: string
          time_zone: string
        }
        Insert: {
          active?: boolean
          code: string
          created_at?: string
          name: string
          time_zone: string
        }
        Update: {
          active?: boolean
          code?: string
          created_at?: string
          name?: string
          time_zone?: string
        }
        Relationships: []
      }
      roster_transactions: {
        Row: {
          action: string
          created_at: string
          id: string
          league_id: string
          metadata: Json
          player_id: string
          related_player_id: string | null
          user_id: string
          week_id: string | null
        }
        Insert: {
          action: string
          created_at?: string
          id?: string
          league_id: string
          metadata?: Json
          player_id: string
          related_player_id?: string | null
          user_id: string
          week_id?: string | null
        }
        Update: {
          action?: string
          created_at?: string
          id?: string
          league_id?: string
          metadata?: Json
          player_id?: string
          related_player_id?: string | null
          user_id?: string
          week_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "roster_transactions_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "roster_transactions_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "roster_transactions_related_player_id_fkey"
            columns: ["related_player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "roster_transactions_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
      score_transactions: {
        Row: {
          category: string
          created_at: string
          description: string
          id: string
          league_id: string | null
          points: number
          reason_code: string
          region_code: string
          reverses_transaction_id: string | null
          rule_set_id: string | null
          season_id: string
          source_id: string | null
          source_table: string | null
          user_id: string
          week_id: string | null
        }
        Insert: {
          category: string
          created_at?: string
          description: string
          id?: string
          league_id?: string | null
          points: number
          reason_code: string
          region_code: string
          reverses_transaction_id?: string | null
          rule_set_id?: string | null
          season_id: string
          source_id?: string | null
          source_table?: string | null
          user_id: string
          week_id?: string | null
        }
        Update: {
          category?: string
          created_at?: string
          description?: string
          id?: string
          league_id?: string | null
          points?: number
          reason_code?: string
          region_code?: string
          reverses_transaction_id?: string | null
          rule_set_id?: string | null
          season_id?: string
          source_id?: string | null
          source_table?: string | null
          user_id?: string
          week_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "score_transactions_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "score_transactions_region_code_fkey"
            columns: ["region_code"]
            isOneToOne: false
            referencedRelation: "regions"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "score_transactions_reverses_transaction_id_fkey"
            columns: ["reverses_transaction_id"]
            isOneToOne: false
            referencedRelation: "score_transactions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "score_transactions_rule_set_id_fkey"
            columns: ["rule_set_id"]
            isOneToOne: false
            referencedRelation: "scoring_rule_sets"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "score_transactions_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "score_transactions_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
      scoring_rule_sets: {
        Row: {
          active: boolean
          created_at: string
          created_by: string | null
          effective_week_id: string | null
          id: string
          rules: Json
          season_id: string
          version: number
        }
        Insert: {
          active?: boolean
          created_at?: string
          created_by?: string | null
          effective_week_id?: string | null
          id?: string
          rules: Json
          season_id: string
          version: number
        }
        Update: {
          active?: boolean
          created_at?: string
          created_by?: string | null
          effective_week_id?: string | null
          id?: string
          rules?: Json
          season_id?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "scoring_rule_sets_effective_week_id_fkey"
            columns: ["effective_week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "scoring_rule_sets_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
        ]
      }
      season_rosters: {
        Row: {
          active: boolean
          created_at: string
          ends_at: string | null
          id: string
          player_id: string
          role: string
          season_id: string
          source_url: string | null
          starts_at: string
          team_id: string
          verified_at: string | null
        }
        Insert: {
          active?: boolean
          created_at?: string
          ends_at?: string | null
          id?: string
          player_id: string
          role: string
          season_id: string
          source_url?: string | null
          starts_at: string
          team_id: string
          verified_at?: string | null
        }
        Update: {
          active?: boolean
          created_at?: string
          ends_at?: string | null
          id?: string
          player_id?: string
          role?: string
          season_id?: string
          source_url?: string | null
          starts_at?: string
          team_id?: string
          verified_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "season_rosters_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "season_rosters_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "season_rosters_team_id_fkey"
            columns: ["team_id"]
            isOneToOne: false
            referencedRelation: "teams"
            referencedColumns: ["id"]
          },
        ]
      }
      seasons: {
        Row: {
          created_at: string
          ends_at: string | null
          id: string
          name: string
          region_code: string
          season_number: number
          starts_at: string | null
          status: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          ends_at?: string | null
          id?: string
          name: string
          region_code: string
          season_number: number
          starts_at?: string | null
          status?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          ends_at?: string | null
          id?: string
          name?: string
          region_code?: string
          season_number?: number
          starts_at?: string | null
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "seasons_region_code_fkey"
            columns: ["region_code"]
            isOneToOne: false
            referencedRelation: "regions"
            referencedColumns: ["code"]
          },
        ]
      }
      survivor_eliminations: {
        Row: {
          eliminated_at: string
          id: string
          league_id: string
          rank_at_elimination: number | null
          tie_break_data: Json
          user_id: string
          week_id: string
          weekly_score: number
        }
        Insert: {
          eliminated_at?: string
          id?: string
          league_id: string
          rank_at_elimination?: number | null
          tie_break_data?: Json
          user_id: string
          week_id: string
          weekly_score: number
        }
        Update: {
          eliminated_at?: string
          id?: string
          league_id?: string
          rank_at_elimination?: number | null
          tie_break_data?: Json
          user_id?: string
          week_id?: string
          weekly_score?: number
        }
        Relationships: [
          {
            foreignKeyName: "survivor_eliminations_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "survivor_eliminations_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
      teams: {
        Row: {
          active: boolean
          code: string
          created_at: string
          id: string
          logo_url: string | null
          name: string
          region_code: string
          source_url: string | null
          updated_at: string
          verified_at: string | null
        }
        Insert: {
          active?: boolean
          code: string
          created_at?: string
          id?: string
          logo_url?: string | null
          name: string
          region_code: string
          source_url?: string | null
          updated_at?: string
          verified_at?: string | null
        }
        Update: {
          active?: boolean
          code?: string
          created_at?: string
          id?: string
          logo_url?: string | null
          name?: string
          region_code?: string
          source_url?: string | null
          updated_at?: string
          verified_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "teams_region_code_fkey"
            columns: ["region_code"]
            isOneToOne: false
            referencedRelation: "regions"
            referencedColumns: ["code"]
          },
        ]
      }
      weekly_lineups: {
        Row: {
          captain_player_id: string | null
          created_at: string
          id: string
          league_id: string
          locked_at: string | null
          status: string
          submitted_at: string | null
          updated_at: string
          user_id: string
          week_id: string
        }
        Insert: {
          captain_player_id?: string | null
          created_at?: string
          id?: string
          league_id: string
          locked_at?: string | null
          status?: string
          submitted_at?: string | null
          updated_at?: string
          user_id: string
          week_id: string
        }
        Update: {
          captain_player_id?: string | null
          created_at?: string
          id?: string
          league_id?: string
          locked_at?: string | null
          status?: string
          submitted_at?: string | null
          updated_at?: string
          user_id?: string
          week_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "weekly_lineups_captain_player_id_fkey"
            columns: ["captain_player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "weekly_lineups_league_id_fkey"
            columns: ["league_id"]
            isOneToOne: false
            referencedRelation: "fantasy_leagues"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "weekly_lineups_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
      weekly_mvp_predictions: {
        Row: {
          id: string
          player_id: string
          submitted_at: string
          updated_at: string
          user_id: string
          week_id: string
        }
        Insert: {
          id?: string
          player_id: string
          submitted_at?: string
          updated_at?: string
          user_id: string
          week_id: string
        }
        Update: {
          id?: string
          player_id?: string
          submitted_at?: string
          updated_at?: string
          user_id?: string
          week_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "weekly_mvp_predictions_player_id_fkey"
            columns: ["player_id"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "weekly_mvp_predictions_week_id_fkey"
            columns: ["week_id"]
            isOneToOne: false
            referencedRelation: "competition_weeks"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      admin_create_match: {
        Args: {
          away_team: string
          home_team: string
          match_time: string
          series_best_of?: number
          target_week: string
        }
        Returns: {
          away_score: number | null
          away_team_id: string
          best_of: number
          created_at: string
          finalized_at: string | null
          home_score: number | null
          home_team_id: string
          id: string
          prediction_locks_at: string
          result_state: string
          scheduled_at: string
          season_id: string
          source_url: string | null
          status: string
          updated_at: string
          week_id: string
          winner_team_id: string | null
        }
        SetofOptions: {
          from: "*"
          to: "matches"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      admin_delete_match: { Args: { target_match: string }; Returns: undefined }
      admin_set_match_result: {
        Args: { away_score: number; home_score: number; target_match: string }
        Returns: {
          away_score: number | null
          away_team_id: string
          best_of: number
          created_at: string
          finalized_at: string | null
          home_score: number | null
          home_team_id: string
          id: string
          prediction_locks_at: string
          result_state: string
          scheduled_at: string
          season_id: string
          source_url: string | null
          status: string
          updated_at: string
          week_id: string
          winner_team_id: string | null
        }
        SetofOptions: {
          from: "*"
          to: "matches"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      admin_set_weekly_mvp: {
        Args: { target_player: string; target_week: string }
        Returns: undefined
      }
      admin_update_match_schedule: {
        Args: { new_status?: string; new_time?: string; target_match: string }
        Returns: {
          away_score: number | null
          away_team_id: string
          best_of: number
          created_at: string
          finalized_at: string | null
          home_score: number | null
          home_team_id: string
          id: string
          prediction_locks_at: string
          result_state: string
          scheduled_at: string
          season_id: string
          source_url: string | null
          status: string
          updated_at: string
          week_id: string
          winner_team_id: string | null
        }
        SetofOptions: {
          from: "*"
          to: "matches"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      admin_upsert_player_stat: {
        Args: {
          assist_count: number
          kill_count: number
          target_match: string
          target_player: string
          target_team: string
        }
        Returns: {
          assists: number
          created_at: string
          entered_by: string | null
          id: string
          kills: number
          match_id: string
          player_id: string
          team_id: string
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "player_match_stats"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      admin_upsert_week: {
        Args: {
          target_season: string
          week_ends: string
          week_num: number
          week_starts: string
        }
        Returns: {
          created_at: string
          ends_at: string
          finalized_at: string | null
          id: string
          meta_locks_at: string
          mvp_locks_at: string
          name: string
          season_id: string
          starts_at: string
          updated_at: string
          week_number: number
        }
        SetofOptions: {
          from: "*"
          to: "competition_weeks"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      export_my_data: { Args: Record<PropertyKey, never>; Returns: Json }
      delete_my_account: { Args: { confirmation_name: string }; Returns: undefined }
      my_dashboard_summary: { Args: { target_region: string }; Returns: Json }
      my_account_bootstrap: { Args: Record<PropertyKey, never>; Returns: Json }
      configure_pandascore_sync_secret: { Args: { raw_secret: string }; Returns: undefined }
      ingest_pandascore_fixture_batch: { Args: { raw_secret: string; matches: Json }; Returns: Json }
      admin_map_pandascore_team: { Args: { external_id: number; target_team: string }; Returns: undefined }
      admin_apply_pandascore_fixtures: { Args: { target_region: string }; Returns: Json }
      admin_pandascore_sync_status: { Args: { target_region: string }; Returns: Json }
      admin_live_overview: { Args: { target_region: string }; Returns: Json }
      admin_publish_weekly_mvp: { Args: { target_week: string; target_player: string; target_source_url: string }; Returns: undefined }
      current_regional_fantasy_week: { Args: { target_region:string }; Returns:string }
      save_regional_fantasy_lineup: { Args: { target_week:string; target_captain:string; selections:Json }; Returns:string }
      score_week_regional_fantasy: { Args: { target_week:string }; Returns: { lineups_scored:number; transactions_created:number }[] }
      save_my_meta_prediction: { Args: { target_region:string; payload:Json; submit?:boolean }; Returns:Json }
      admin_publish_meta_result: { Args: { target_week:string; payload:Json; target_source_url:string }; Returns:undefined }
      score_week_meta: { Args: { target_week:string }; Returns:{ predictions_scored:number; transactions_created:number }[] }
      update_my_profile: {
        Args: {
          new_manager_name: string
          new_country_code: string
          new_bio: string
          new_avatar_url: string
          new_full_name: string
          new_address: string
          new_date_of_birth: string | null
        }
        Returns: Json
      }
      beta_activity_counts: { Args: Record<PropertyKey, never>; Returns: Json }
      preview_beta_activity_reset: { Args: Record<PropertyKey, never>; Returns: Json }
      run_beta_activity_reset: { Args: { confirmation: string }; Returns: Json }
      draft_intelligence_status: { Args: { target_region: string }; Returns: Json }
      draft_model_bundle: { Args: { target_region: string }; Returns: Json }
      regional_feature_status: { Args: { target_region: string }; Returns: Json }
      admin_set_regional_feature: { Args: { target_region: string; target_feature: string; target_enabled: boolean; target_message?: string }; Returns: undefined }
      admin_refresh_leaderboard_snapshots: { Args: { target_region: string; target_week?: string }; Returns: Json }
      admin_regional_operations_status: { Args: { target_region: string }; Returns: Json }
      regional_leaderboard_snapshot: {
        Args: { target_region: string; target_season?: string; target_week?: string; max_rows?: number }
        Returns: {
          user_id: string
          manager_name: string
          country_code: string
          avatar_url: string
          total_points: number
          prediction_points: number
          fantasy_points: number
          rank_position: number
          generated_at: string
        }[]
      }
      recommend_draft_actions: {
        Args: {
          target_region: string
          target_action: string
          ally_hero_names?: string[]
          enemy_hero_names?: string[]
          banned_hero_names?: string[]
          max_results?: number
        }
        Returns: {
          hero_name: string
          score: number
          evidence_level: string
          sample_size: number
          reason: string
          pick_rate: number
          ban_rate: number
          win_rate: number
          contest_rate: number
        }[]
      }
      admin_upsert_draft_source: {
        Args: {
          source_name: string
          source_provider_url: string
          source_terms_url?: string
          source_license_name?: string
          source_attribution_text?: string
          source_approval_status?: string
          source_commercial_confirmed?: boolean
          source_primary?: boolean
          source_notes?: string
        }
        Returns: string
      }
      admin_draft_intelligence_config: { Args: Record<PropertyKey, never>; Returns: Json }
      admin_import_hero_metrics: {
        Args: { target_source: string; target_patch: string; target_region: string; metrics: Json }
        Returns: Json
      }
      admin_activate_draft_model: {
        Args: { target_model: string; target_patch: string; target_minimum_sample?: number }
        Returns: undefined
      }
      rebuild_draft_intelligence_metrics: {
        Args: { target_source: string; target_patch: string; target_region: string }
        Returns: Json
      }
      admin_import_pro_draft_game: {
        Args: {
          target_source: string
          target_patch: string
          target_region: string
          target_source_match_key: string
          target_game_number: number
          target_played_at: string
          target_blue_team_code: string
          target_red_team_code: string
          target_winner_side: string
          target_source_url: string
          target_actions: Json
        }
        Returns: Json
      }
      auto_pick_expired_turn: {
        Args: { target_draft: string }
        Returns: {
          auto_picked: boolean
          draft_id: string
          id: string
          league_id: string
          pick_number: number
          picked_at: string
          player_id: string
          round_number: number
          user_id: string
        }
        SetofOptions: {
          from: "*"
          to: "draft_picks"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      can_manage_league: { Args: { target_league: string }; Returns: boolean }
      ensure_league_draft: {
        Args: { schedule_at?: string; target_league: string }
        Returns: {
          completed_at: string | null
          created_at: string
          current_pick_number: number
          id: string
          league_id: string
          manager_count: number | null
          roster_size: number
          scheduled_at: string | null
          started_at: string | null
          status: string
          turn_expires_at: string | null
          updated_at: string
        }
        SetofOptions: {
          from: "*"
          to: "drafts"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      fantasy_rule: {
        Args: { fallback: number; rule_key: string; season: string }
        Returns: number
      }
      generate_invite_code: { Args: never; Returns: string }
      is_league_member: { Args: { target_league: string }; Returns: boolean }
      is_platform_admin: { Args: never; Returns: boolean }
      join_league_by_code: { Args: { requested_code: string }; Returns: string }
      join_public_league: { Args: { target_league: string }; Returns: string }
      league_standings: {
        Args: { target_league: string }
        Returns: {
          country_code: string
          manager_name: string
          total_points: number
          user_id: string
          weeks_scored: number
        }[]
      }
      list_public_leagues: {
        Args: { requested_format?: string; requested_season?: string }
        Returns: {
          active_managers: number
          commissioner_id: string
          creator_profile_id: string
          description: string
          format: string
          id: string
          max_managers: number
          name: string
          scoring_ends_at: string
          scoring_starts_at: string
          season_id: string
          status: string
        }[]
      }
      make_draft_pick: {
        Args: { selected_player: string; target_draft: string }
        Returns: {
          auto_picked: boolean
          draft_id: string
          id: string
          league_id: string
          pick_number: number
          picked_at: string
          player_id: string
          round_number: number
          user_id: string
        }
        SetofOptions: {
          from: "*"
          to: "draft_picks"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      make_transfer: {
        Args: { player_in: string; player_out: string; target_league: string }
        Returns: undefined
      }
      my_week_points: {
        Args: { target_week: string }
        Returns: {
          category: string
          created_at: string
          description: string
          points: number
          reason_code: string
        }[]
      }
      regional_leaderboard: {
        Args: {
          max_rows?: number
          target_region: string
          target_season?: string
        }
        Returns: {
          avatar_url: string
          country_code: string
          fantasy_points: number
          manager_name: string
          prediction_points: number
          total_points: number
          user_id: string
        }[]
      }
      score_week_fantasy: {
        Args: { target_week: string }
        Returns: {
          lineups_scored: number
          transactions_created: number
        }[]
      }
      score_week_predictions: {
        Args: { target_week: string }
        Returns: {
          predictions_scored: number
          transactions_created: number
        }[]
      }
      start_league_draft: { Args: { target_draft: string }; Returns: undefined }
      submit_h2h_ban: {
        Args: { target_matchup: string; target_player: string }
        Returns: string
      }
      submit_weekly_lineup: {
        Args: { target_lineup: string }
        Returns: {
          captain_player_id: string | null
          created_at: string
          id: string
          league_id: string
          locked_at: string | null
          status: string
          submitted_at: string | null
          updated_at: string
          user_id: string
          week_id: string
        }
        SetofOptions: {
          from: "*"
          to: "weekly_lineups"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      transfers_used: {
        Args: { target_league: string; target_user: string }
        Returns: number
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const
