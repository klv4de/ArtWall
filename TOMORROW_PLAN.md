# ArtWall - Tomorrow's Action Plan

**Date Created**: August 20, 2024
**Status**: Ready to Execute

## 🎯 **Primary Goal**
Get Kevin 48 high-quality fine art images for 30-minute wallpaper rotations through a single script execution.

## 📋 **Step-by-Step Plan**

### **Step 1: Department Sampling (30 minutes)**
- Run `department_sampler.py` to get 5 examples from each of the 20 Met departments
- Let Kevin review samples and decide which departments to include
- Expected output: `~/Pictures/ArtWall_Samples/` with organized folders

### **Step 2: Department Selection (10 minutes)**
- Kevin reviews sample images from each department
- Decides which departments to include in final filtering
- Expected: 4-8 departments selected (likely European Paintings, Modern Art, Drawings, Photographs, etc.)

### **Step 3: Technical Decision Points (15 minutes)**
**One decision at a time:**
1. **Multi-monitor behavior**: Same image on all screens, or different images?
2. **Automation level**: Should script set up 30-minute rotation, or just prepare images?
3. **Image processing**: Should we crop/resize images to prevent distortion?

### **Step 4: Update Main Script (45 minutes)**
- Modify `main.py` to use API department filtering instead of random sampling
- Target the selected departments with `departmentId` parameter
- Expected improvement: 1% → 20-30% success rate
- Set target to 48 images instead of 336

### **Step 5: Script Enhancement (30 minutes)**
- Add multi-monitor detection and configuration
- Add automated wallpaper rotation setup (if decided)
- Add image optimization for screen resolution

### **Step 6: Testing & Delivery (30 minutes)**
- Run the enhanced script to get Kevin's 48 images
- Verify wallpaper setup works correctly
- Test on Kevin's multi-monitor setup

## 🚫 **Potential Blockers**
- **API Rate Limiting**: If Met API is still restrictive, we'll implement longer delays
- **Multi-monitor Complexity**: macOS automation might require additional AppleScript development
- **Image Quality**: May need additional filtering iterations based on results

## 📊 **Success Metrics**
- ✅ 48 high-quality images downloaded
- ✅ No museum catalog photos, fragments, or small objects
- ✅ Proper aspect ratios for desktop use
- ✅ Automated wallpaper rotation working
- ✅ Multi-monitor setup configured correctly

## 🔄 **Backup Plan**
If API issues persist:
- Use existing successful filtering approach with longer delays
- Focus on 3-4 most promising departments only
- Build collection incrementally over multiple sessions

---
**Estimated Total Time**: 2.5 hours
**Expected Outcome**: Kevin has a fully working fine art wallpaper system
