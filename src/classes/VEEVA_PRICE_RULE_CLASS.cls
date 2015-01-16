/******************************************************************************
 *                                                                              
 *               Confidentiality Information:
 *
 * This module is the confidential and proprietary information of
 * Verticals onDemand, Inc.; it is not to be copied, reproduced, or transmitted
 * in any form, by any means, in whole or in part, nor is it to be used
 * for any purpose other than that for which it is expressly provided
 * without the written permission of Verticals onDemand.
 * 
 * Copyright (c) 2010 Veeva Systems , Inc.  All Rights Reserved.
 *
 *******************************************************************************/

public with sharing class VEEVA_PRICE_RULE_CLASS {
  public String External_Id_vod;
  public Double Min_val;
  public Double Max_val;
  public Date Start_date;
  public Date End_date;
  
  public VEEVA_PRICE_RULE_CLASS (String pExternal_Id_vod, Double pMin_val, Double pMax_val) {
    External_Id_vod = pExternal_Id_vod;
    Min_val = pMin_val;
    Max_val = pMax_val;
  }
  public VEEVA_PRICE_RULE_CLASS (String pExternal_Id_vod, Decimal pMin_val, Decimal pMax_val) {
    External_Id_vod = pExternal_Id_vod;
    Min_val = pMin_val;
    Max_val = pMax_val;
  }
  public VEEVA_PRICE_RULE_CLASS (String pExternal_Id_vod, Double pMin_val, Double pMax_val,Date dStart,Date dEnd) {
    External_Id_vod = pExternal_Id_vod;
    Min_val = pMin_val;
    Max_val = pMax_val;
    Start_date = dStart;
    End_date = dEnd;
  }
  public VEEVA_PRICE_RULE_CLASS (String pExternal_Id_vod, Decimal pMin_val, Decimal pMax_val,Date dStart,Date dEnd) {
    External_Id_vod = pExternal_Id_vod;
    Min_val = pMin_val;
    Max_val = pMax_val;
    Start_date = dStart;
    End_date = dEnd;
  }  
}