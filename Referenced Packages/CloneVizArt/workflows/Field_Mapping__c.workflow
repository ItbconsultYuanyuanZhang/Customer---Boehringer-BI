<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Object_Key</fullName>
        <field>Object_Key__c</field>
        <formula>LOWER(TRIM(Name)) &amp; &quot;|&quot; &amp; TRIM(Key__c)</formula>
        <name>Populate Object Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>true</protected>
    </fieldUpdates>
    <rules>
        <fullName>Generate Object Key</fullName>
        <actions>
            <name>Populate_Object_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Concatenates object name and key for lookup purposes</description>
        <formula>OR(ISNEW(), ISCHANGED(Name), ISCHANGED(Key__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
