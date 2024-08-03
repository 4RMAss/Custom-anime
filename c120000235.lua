-- Harpie Replication
-- scripted by: YourName
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
    return c:IsCode(76812113) and c:IsFaceup() -- Harpie Lady
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    local tc=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_MZONE,0,nil,e,tp)
    if tc then
        local atk=tc:GetBaseAttack() -- Obtenemos el ATK base original
        local def=tc:GetDefense()
        local race=tc:GetRace()
        local att=tc:GetAttribute()
        local lvl=tc:GetLevel()
        local code=tc:GetOriginalCode()
        for i=1,2 do
            local token=Duel.CreateToken(tp,code)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,tc:GetPosition())
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_BASE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            token:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_BASE_DEFENSE)
            e2:SetValue(def)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            token:RegisterEffect(e2)
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_CHANGE_RACE)
            e3:SetValue(race)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            token:RegisterEffect(e3)
            local e4=Effect.CreateEffect(e:GetHandler())
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
            e4:SetValue(att)
            e4:SetReset(RESET_EVENT+RESETS_STANDARD)
            token:RegisterEffect(e4)
            local e5=Effect.CreateEffect(e:GetHandler())
            e5:SetType(EFFECT_TYPE_SINGLE)
            e5:SetCode(EFFECT_CHANGE_LEVEL)
            e5:SetValue(lvl)
            e5:SetReset(RESET_EVENT+RESETS_STANDARD)
            token:RegisterEffect(e5)
        end
        Duel.SpecialSummonComplete()
    end
end
