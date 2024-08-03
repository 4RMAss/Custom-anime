--オレイカルコスの結界
--The Seal of Orichalcos
local s,id=GetID()
function s.initial_effect(c)
    -- Hacer que la carta sea una carta de campo
    c:EnableReviveLimit()

    -- Efecto para aumentar el ATK de tus monstruos en 500 puntos
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetValue(500)
    c:RegisterEffect(e1)

    -- Efecto para activar la carta de campo
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e2)

    -- Efecto para proteger la carta de ser destruida
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_FZONE, 0)
    e3:SetValue(s.indct)
    c:RegisterEffect(e3)

    -- Efecto para proteger la carta de ser negada al activarse
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e4:SetCode(EFFECT_CANNOT_DISEFFECT)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_FZONE, 0)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    -- Efecto para mover monstruos a la zona de mágicas y trampas (una vez por turno)
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1, id)
    e5:SetTarget(s.mvtg)
    e5:SetOperation(s.mvop)
    c:RegisterEffect(e5)

    -- Efecto para invocar monstruos desde la zona de mágicas y trampas (una vez por turno)
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 1))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCountLimit(1, id+1)
    e6:SetTarget(s.sptg)
    e6:SetOperation(s.spop)
    c:RegisterEffect(e6)

    -- Efecto para invocar monstruos movidos cuando un monstruo es destruido por batalla y no controlas monstruos
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 2))
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_BATTLE_DESTROYED)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCondition(s.spcon2)
    e7:SetTarget(s.sptg2)
    e7:SetOperation(s.spop2)
    c:RegisterEffect(e7)

    -- Efecto para invocar monstruos movidos cuando un monstruo deja el campo por el efecto de una carta y no controlas monstruos
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id, 3))
    e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e8:SetCode(EVENT_LEAVE_FIELD)
    e8:SetRange(LOCATION_FZONE)
    e8:SetCondition(s.spcon3)
    e8:SetTarget(s.sptg3)
    e8:SetOperation(s.spop3)
    c:RegisterEffect(e8)

    -- Registro de monstruos movidos a la zona de mágicas y trampas
    if not s.global_check then
        s.global_check=true
        s[0]=Group.CreateGroup()
        s[0]:KeepAlive()
        s[1]=Group.CreateGroup()
        s[1]:KeepAlive()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_MOVE)
        ge1:SetOperation(s.regop)
        Duel.RegisterEffect(ge1,0)
    end
end

-- Contador para efectos de destrucción
function s.indct(e,re,r,rp)
    return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and 1 or 0
end

-- Registro de monstruos movidos a la zona de mágicas y trampas
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if tc:IsLocation(LOCATION_SZONE) and tc:IsControler(tp) then
            s[tp]:AddCard(tc)
        end
        tc=eg:GetNext()
    end
end

-- Selección de monstruos para mover a la zona de mágicas y trampas
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.mvfilter,tp,LOCATION_MZONE,0,1,nil) end
end

-- Filtro para seleccionar monstruos que pueden ser movidos
function s.mvfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end

-- Operación para mover los monstruos a la zona de mágicas y trampas
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
    local g=Duel.SelectMatchingCard(tp,s.mvfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            s[tp]:AddCard(tc)
        end
    end
end

-- Selección de monstruos para invocar desde la zona de mágicas y trampas
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end

-- Filtro para seleccionar monstruos que pueden ser invocados
function s.spfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:GetType()&TYPE_MONSTER~=0
end

-- Operación para invocar los monstruos desde la zona de mágicas y trampas
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Condición para invocar monstruos cuando uno es destruido por batalla y no controlas monstruos
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- Filtro para verificar si un monstruo fue destruido por batalla
function s.cfilter(c,tp)
    return c:IsReason(REASON_BATTLE) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
end

-- Selección de monstruos movidos para invocar desde la zona de mágicas y trampas
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return s[tp]:IsExists(s.spfilter2,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end

-- Filtro para seleccionar monstruos movidos que pueden ser invocados
function s.spfilter2(c,e,tp)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLocation(LOCATION_SZONE)
end

-- Operación para invocar los monstruos movidos desde la zona de mágicas y trampas
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local g=s[tp]:Filter(s.spfilter2,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Condición para invocar monstruos cuando uno deja el campo por el efecto de una carta y no controlas monstruos
function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter2,1,nil,tp) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- Filtro para verificar si un monstruo dejó el campo por el efecto de una carta
function s.cfilter2(c,tp)
    return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
end

-- Selección de monstruos movidos para invocar desde la zona de mágicas y trampas
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return s[tp]:IsExists(s.spfilter2,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end

-- Operación para invocar los monstruos movidos desde la zona de mágicas y trampas
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
    local g=s[tp]:Filter(s.spfilter2,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
