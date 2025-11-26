# Heroes Colombia Marketplace Enhancement Roadmap
## Solo Developer Plan | Launch: December 5, 2025

**Created**: January 20, 2025
**Last Updated**: January 20, 2025
**Status**: In Planning
**Developer**: Solo
**Timeline**: 42 weeks (Feb - Dec 2025)

---

## Executive Summary

Transform Heroes Colombia from a basic business directory into a **world-class discovery platform** rivaling Rappi Colombia, with personalized recommendations, social proof, and engagement features that drive daily usage.

**Key Success Factors**:
1. ✅ **Excellent analytics foundation** - Already tracking user behavior
2. ✅ **Clean architecture** - BLoC pattern enables rapid feature development
3. ✅ **Strong business model** - Tier-based subscriptions with clear upgrade path
4. 🎯 **Focus on engagement** - Features that drive Enterprise upgrades

**Revenue Strategy**: Build features that make businesses DEMAND premium placement → Drive Enterprise upgrades ($150K+ COP/month)

---

## Business Model Alignment

Based on your tier system ([plan-limits.ts](../heroes-colombia-dashboard/lib/plan-limits.ts)):

| Plan | Price | Key Limits | Target Features to Drive Upgrades |
|------|-------|------------|-----------------------------------|
| **Gratis** | Pay-per-promotion | 1 location, $11,900/promo | Show analytics preview → drive to Básico |
| **Básico** | ~$50K/month | 3 locations, 3 promos | Limited analytics → drive to Pro |
| **Pro** | ~$150K/month | 10 locations, 10 promos, advanced analytics | Audience segmentation, per-location data |
| **Enterprise** | ~$300K+/month | Unlimited, featured placement | **Featured carousel**, top search results |

**Marketplace Strategy**: Enterprise businesses get **3-5x more impressions** via featured placement. Make this so valuable that high-volume businesses can't refuse.

---

## Phase Breakdown (42 Weeks)

### Phase 1: Foundation (Weeks 1-4) | Feb 2025
**Goal**: Fix scalability issues, polish UI to Rappi standards

#### Week 1-2: Performance & Data Optimization
- ✅ **Pagination** for all business feeds
  - Implement infinite scroll
  - Add `lastDocument` cursor to cubits
  - Load 10 businesses at a time (not all at once)
  - **Impact**: Handles 100+ businesses without lag
  - **Effort**: 2 days

- ✅ **Response Caching** (5-minute TTL)
  - Cache home feed, categories, featured businesses
  - Use Hive for persistent cache
  - **Impact**: 70% reduction in Firestore reads = cost savings
  - **Effort**: 1 day

- ✅ **Image Lazy Loading**
  - Replace `Image.network` with `cached_network_image`
  - Preload images in viewport
  - **Impact**: Faster scrolling, less data usage
  - **Effort**: 1 day

#### Week 3-4: Visual Polish (Rappi Parity)
- ✅ **Distance indicators** on business cards
  - Calculate from user location
  - Show "1.2 km" badge
  - **Impact**: Users find nearby businesses faster
  - **Effort**: 1 day

- ✅ **Estimated travel time**
  - Google Maps Distance Matrix API
  - Show "15 min drive" on detail pages
  - **Impact**: Helps users plan visits
  - **Effort**: 2 days

- ✅ **"Premium" badge** for Enterprise businesses
  - Gold ⭐ badge if `plan === "enterprise"`
  - Creates aspiration for other businesses
  - **Impact**: Social proof for premium tier
  - **Effort**: 0.5 days

- ✅ **Pricing display** on promotion cards
  - Show original price (strikethrough) + discounted price
  - Optional field: `original_price` in promotions
  - **Impact**: Better value communication
  - **Effort**: 1 day

**Deliverable**: App loads fast, looks polished, scales to 100s of businesses

---

### Phase 2: Discovery (Weeks 5-10) | March 2025
**Goal**: Help users discover relevant businesses without manual search

#### Week 5-6: Trending Section
- ✅ **"Popular This Week" algorithm**
  - Query `analytics_events` for past 7 days
  - Count views per business
  - Cache for 1 hour
  - **Technical Approach**:
    ```dart
    Future<List<Business>> getPopularThisWeek() async {
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      final events = await firestore
        .collection('analytics_events')
        .where('event_type', isEqualTo: 'view')
        .where('entity_type', isEqualTo: 'business')
        .where('timestamp', isGreaterThan: sevenDaysAgo)
        .get();

      // Group by business_id, count occurrences, sort descending
      // Return top 10
    }
    ```
  - **Impact**: Discovery without complex ML
  - **Effort**: 2 days

- ✅ **Add "Trending" section** to home feed
  - Horizontal carousel after featured promotions
  - 🔥 Fire emoji badge on cards
  - **Impact**: Users discover popular businesses
  - **Effort**: 1 day

#### Week 7-8: "For You" Personalization
- ✅ **Favorite-based recommendations**
  - Analyze user's `favourite_businesses` array
  - Find most common categories
  - Recommend businesses in those categories (exclude already favorited)
  - **Algorithm**: Collaborative filtering (simple version)
  - **Fallback**: New users see "Popular This Week" instead
  - **Impact**: 30-50% engagement lift (industry standard)
  - **Effort**: 3 days

- ✅ **"Para Ti" section** at top of home feed
  - ✨ "Seleccionado para ti" subtitle
  - Track impressions separately (analytics)
  - **Impact**: Users feel app understands them
  - **Effort**: 1 day

#### Week 9-10: Advanced Filtering
- ✅ **Sort options** in All Business view
  - Nearest (geospatial query)
  - Most Popular (from analytics)
  - Highest Rated (future - needs ratings)
  - Newest (created_at DESC)
  - **Impact**: Users find what they need faster
  - **Effort**: 2 days

- ✅ **Filter modal**
  - Distance radius: < 1km, < 5km, < 10km, Any
  - Has active promotions (toggle)
  - Open now (future - needs business hours)
  - **Impact**: Better search experience
  - **Effort**: 2 days

- ✅ **Track filter usage** in analytics
  - Log which filters are most used
  - Inform future features
  - **Effort**: 0.5 days

**Deliverable**: Users discover businesses organically (not just search)

---

### Phase 3: Social Proof (Weeks 11-16) | Apr-May 2025
**Goal**: Build trust through ratings & reviews

#### Week 11-13: Ratings & Reviews System (Option B)
**📄 Detailed Plan**: [RATINGS_REVIEWS_SYSTEM_IMPLEMENTATION.md](./RATINGS_REVIEWS_SYSTEM_IMPLEMENTATION.md)

**Summary**:
- ✅ **Two-tier system**: Quick ratings (5 sec) + optional reviews (2 min)
- ✅ **Two collections**: `ratings/` + `reviews/` (separate from business docs)
- ✅ **Denormalized summary** in business docs (performance)
- ✅ **Cloud Functions** auto-update averages
- ✅ **Moderation workflow** for reviews (not ratings)

**Key Features**:
1. **Quick Rating Modal**: ⭐⭐⭐⭐⭐ (1-5 stars, no text required)
2. **Full Review Page**: Rating + title + comment + photos (optional)
3. **Review Display**: Pagination, sort by helpful/recent, flag abuse
4. **Business Cards**: Show ★ 4.3 (127) on all listings

**Migration**: Convert existing embedded reviews → new collections

**Impact**:
- Users more likely to leave feedback (quick vs. lengthy)
- Social proof increases conversions by 20-30%
- Businesses see value in ratings → drive Pro/Enterprise upgrades

**Effort**: 8 days total
- Models & services: 3 days
- UI components: 3 days
- Migration & Cloud Functions: 2 days

#### Week 14-16: Social Features
- ✅ **"Recently Viewed" section**
  - Store last 10 viewed business IDs (local storage)
  - Horizontal carousel in home feed
  - **Impact**: Easy return to browsed businesses
  - **Effort**: 1 day

- ✅ **Share functionality**
  - Deep links via Firebase Dynamic Links
  - Share to WhatsApp/Instagram with preview
  - Track shares in analytics
  - **Impact**: Viral growth
  - **Effort**: 2 days

- ✅ **Social proof badges**
  - "X personas guardaron esto esta semana"
  - Show if `saves_count > 10` in past 7 days (from analytics)
  - **Impact**: FOMO effect
  - **Effort**: 1 day

**Deliverable**: Users trust businesses, share with friends

---

### Phase 4: Engagement (Weeks 17-22) | May-June 2025
**Goal**: Drive retention, increase daily opens

#### Week 17-19: Referral System
- ✅ **Referral schema**: `referrals/` collection
- ✅ **Unique referral codes**: "HERO-{FIRSTNAME}"
- ✅ **Invite page**: Share via WhatsApp/Instagram
- ✅ **Rewards**: Gamification-based (badges, not money)
  - Referrer: "Referral Master" badge
  - Referee: "Welcome" badge (30 days)
- ✅ **Signup integration**: Optional referral code field

**Impact**: 10-15% viral growth (industry standard)
**Effort**: 3 days

#### Week 20-22: Gamification
- ✅ **Badge system**:
  - Explorer: Visited 5 businesses
  - Saver: Favorited 10 businesses
  - Local Hero: Supported 3 businesses in your city
  - Early Bird: First 100 users
  - Referral Master: Invited 3+ friends
  - Streak Keeper: 7-day login streak

- ✅ **"Achievements" page**:
  - Grid of earned + locked badges
  - Progress bars: "Explorer: 3/5 businesses visited"

- ✅ **Login streaks**:
  - Track `last_opened_app` in user document
  - Increment `login_streak` if < 24 hours gap
  - Award badge at 7 days
  - Push notification: "You're on a 5-day streak!"

**Impact**: 25-40% engagement lift (Duolingo-level retention)
**Effort**: 4-5 days

**Deliverable**: Users come back daily, feel rewarded

---

### Phase 5: Curated Discovery (Weeks 23-26) | July 2025
**Goal**: Editorial curation, always fresh content

#### Week 23-24: Collections System
- ✅ **Collections schema**: `curated_collections/`
- ✅ **Admin builder**: Dashboard page to create/edit
  - Search and add businesses
  - Drag to reorder
  - Upload featured image
- ✅ **Consumer view**: Collections carousel
  - "Best for Weekend Brunch"
  - "Top Gyms in Bogotá"
  - "Family-Friendly Restaurants"

**Impact**: Showcase best businesses, drive discovery
**Effort**: 5 days

#### Week 25-26: "New This Week" Section
- ✅ **Query businesses** created in past 7 days
- ✅ **🆕 Badge** on cards
- ✅ **Carousel** in home feed

**Impact**: Always fresh content
**Effort**: 2 days

**Deliverable**: Curated experience like premium marketplaces

---

### Phase 6: Advanced Personalization (Weeks 27-32) | Aug-Sep 2025
**Goal**: ML-powered recommendations

#### Week 27-29: Collaborative Filtering V2
- ✅ **"Users Like You" algorithm**:
  - Find users with similar favorites (Jaccard similarity)
  - Recommend what they favorited that you haven't
  - **Technical Approach**:
    ```dart
    // 1. Get user's favorites
    // 2. Find users with ≥2 overlapping favorites
    // 3. Calculate similarity scores
    // 4. Recommend favorites from most similar users
    ```
  - **Impact**: Netflix-level recommendations
  - **Effort**: 4 days

- ✅ **"Users Like You Also Liked"** on business detail pages
  - **Effort**: 1 day

#### Week 30-32: Rank-Based Targeting (Pro+ Feature)
- ✅ **Military rank preferences**:
  - Analyze `user_rank` in analytics events
  - Find patterns: "Officers prefer gyms, Enlisted prefer restaurants"
  - Recommend based on rank cohort

- ✅ **Business: Audience segmentation UI**:
  - Pro+ businesses can target promotions by rank
  - Add `target_ranks` field to promotions
  - Filter feed based on user rank

**Impact**:
- Better targeting for businesses → Pro upgrades
- More relevant promotions for users

**Effort**: 5 days

**Deliverable**: Truly personalized experience, Pro feature value demonstrated

---

### Phase 7: Search & Discovery (Weeks 33-36) | October 2025
**Goal**: Best-in-class search

#### Week 33-35: Algolia Integration
- ✅ **Set up Algolia account**
- ✅ **Sync Firestore → Algolia**:
  - Cloud Function trigger on write
  - Index: name, category, description, location
- ✅ **Instant search**:
  - Results as you type
  - Highlight matched text
- ✅ **Search suggestions**:
  - Recent searches (local)
  - Trending searches (from analytics)

**Impact**: Lightning-fast search (Rappi-level)
**Effort**: 6 days

#### Week 36: Search Analytics
- ✅ **Track queries**: `search_queries/` collection
- ✅ **Admin insights**: "Top searches with no results"

**Impact**: Understand user intent, add missing businesses
**Effort**: 1 day

**Deliverable**: World-class search experience

---

### Phase 8: Final Polish (Weeks 37-40) | November 2025
**Goal**: Production-ready, bug-free

#### Week 37-38: Performance Optimization
- ✅ **Image CDN** (Cloudinary):
  - Resize images based on screen size
  - WebP format for smaller files
  - **Effort**: 2 days

- ✅ **Skeleton loaders**:
  - Replace CircularProgressIndicator
  - Content-aware loading states
  - **Effort**: 1 day

- ✅ **Optimize Firestore queries**:
  - Add composite indexes
  - Minimize read operations
  - **Effort**: 1 day

#### Week 39-40: Testing & Bug Fixes
- ✅ **User testing** with 10-20 military personnel
  - Gather feedback
  - Fix critical bugs
  - **Effort**: 1 week

- ✅ **App Store optimization**:
  - Screenshots
  - Description
  - Keywords
  - **Effort**: 2 days

**Deliverable**: Polished, production-ready app

---

### Phase 9: Pre-Launch (Weeks 41-42) | Late Nov 2025
**Goal**: Marketing, onboarding

#### Week 41: Soft Launch
- ✅ **Beta launch** to 50 users
  - Monitor crashes (Firebase Crashlytics)
  - Track onboarding completion
  - **Effort**: 3 days

- ✅ **Iterate** based on feedback
  - Quick fixes
  - **Effort**: 2 days

#### Week 42: Official Launch Prep
- ✅ **Onboarding flow**:
  - 3-screen intro: "Discover", "Save", "Redeem"
  - **Effort**: 1 day

- ✅ **Marketing materials**:
  - Social media posts
  - Email campaign
  - **Effort**: 2 days

**🚀 Launch Date**: December 5, 2025

---

## MVP Features (If Behind Schedule)

**Must-Have** (60% of roadmap):
1. ✅ Pagination & caching (Week 1-2)
2. ✅ Visual polish (Week 3-4)
3. ✅ Trending section (Week 5-6)
4. ✅ "For You" recommendations (Week 7-8)
5. ✅ Sort & filter (Week 9-10)
6. ✅ **Ratings & reviews system** (Week 11-13) ← **CRITICAL**
7. ✅ Referral program (Week 17-19)
8. ✅ Basic gamification (Week 20-22)

**Nice-to-Have** (40% of roadmap):
- Collections
- Advanced ML recommendations
- Algolia search
- Social features (share, recently viewed)

---

## Success Metrics

### User Engagement (Track via Analytics)
- **DAU/MAU ratio**: > 30% (daily active / monthly active)
- **Session duration**: > 3 minutes average
- **Businesses favorited per user**: > 5
- **Rating submission rate**: > 15% (users who view → rate)
- **Referral rate**: > 10% (users who invite friends)

### Business Metrics (Revenue Drivers)
- **Enterprise upgrades**: 5+ businesses by launch
- **Average businesses in feed**: 50+
- **Promotion engagement**: > 15% (views → saves)
- **Businesses with ratings**: > 80% of total

### Technical Metrics
- **App load time**: < 2 seconds
- **Firestore read cost**: < $50/month (with caching)
- **Crash-free rate**: > 99.5%

---

## Implementation Priorities

### Critical Path (Can't Skip)
1. **Pagination** (scalability)
2. **Caching** (cost savings)
3. **Ratings system** (social proof)
4. **Personalization** (engagement)

### High ROI (Low Effort)
1. **Distance badges** (1 day → instant value)
2. **Premium badges** (0.5 days → drives upgrades)
3. **Trending section** (2 days → discovery)
4. **Recently viewed** (1 day → retention)

### Complex But Essential
1. **Ratings & reviews** (8 days → trust)
2. **Algolia search** (6 days → UX)
3. **Collaborative filtering** (4 days → personalization)

---

## Technical Stack Additions

### New Dependencies
```yaml
# pubspec.yaml
dependencies:
  # Caching
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Better image loading
  cached_network_image: ^3.3.1

  # Search (Week 33)
  algolia: ^1.1.1

  # Deep linking (referrals)
  firebase_dynamic_links: ^5.4.0

  # Already have:
  # - geolocator (distance calculations)
  # - firebase_analytics (tracking)
  # - cloud_firestore (database)
```

### Cloud Functions (New)
```javascript
// functions/src/index.ts

// Auto-update denormalized data
exports.onRatingChanged = functions.firestore
  .document('ratings/{ratingId}')
  .onWrite(async (change, context) => {
    // Recalculate business rating_average
  });

exports.onReviewApproved = functions.firestore
  .document('reviews/{reviewId}')
  .onUpdate(async (change, context) => {
    // Update business review_count and recent_reviews
  });
```

---

## Migration Plan

### Existing Reviews → New Collections
**Script**: `scripts/migrate_reviews_to_collections.dart`

**Steps**:
1. Read all businesses with embedded reviews
2. Create documents in `ratings/` collection (one per review)
3. Create documents in `reviews/` collection (if review has text)
4. Calculate `rating_average`, `rating_count`, `rating_distribution`
5. Update business documents with denormalized data
6. Keep `reviews_backup` field (safety)

**Run time**: ~5 minutes for 100 businesses
**Reversible**: Yes (backup field preserved)

---

## Risk Mitigation

### Solo Developer Challenges
**Risk**: Feature creep, missed deadlines
**Mitigation**: Stick to MVP list if behind schedule

**Risk**: Burnout
**Mitigation**:
- Work in 2-week sprints
- Take 1 week off every 8 weeks
- Don't work weekends

**Risk**: Technical blockers (Cloud Functions, Algolia)
**Mitigation**:
- Test each integration early (Week 1 for caching, Week 11 for Cloud Functions)
- Have fallback plans (skip Algolia if needed, use client-side search)

### Business Risks
**Risk**: Low business adoption of premium tiers
**Mitigation**: Analytics dashboard shows clear value (impressions, conversions)

**Risk**: Users don't leave ratings
**Mitigation**:
- Prompt at strategic times (after favoriting, after 30 sec view)
- Make it FAST (5 seconds, not 5 minutes)
- Show social proof ("Join 127 others who rated this")

---

## Next Steps

1. ✅ **Review this roadmap** - Any changes needed?
2. ⏳ **Set up project board** - GitHub Projects or Notion?
3. ⏳ **Start Week 1** - Pagination + caching (highest ROI)
4. ⏳ **Schedule check-ins** - Bi-weekly review of progress

---

## Questions?

Want me to create:
1. **Detailed implementation guides** for specific features?
2. **Code templates** for recommendation algorithms?
3. **Figma wireframes** for new UI sections?
4. **Firebase schema migration** scripts?

**Ready to start? Let's build! 🚀**