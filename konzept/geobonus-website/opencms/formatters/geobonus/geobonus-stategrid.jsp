<%@page pageEncoding="UTF-8" buffer="none" session="false" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m"   tagdir="/WEB-INF/tags/mercury" %>

<c:set var="arrowSvg"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M7 17 17 7M7 7h10v10"/></svg></c:set>

<m:init-messages>
<cms:formatter var="content" val="value">
<m:setting-defaults>

<c:set var="ade" value="${cms.isEditMode}" />

<section class="element type-gb-stategrid${setCssWrapperAll}" aria-label="${fn:escapeXml(value.Title)}"><%----%>
    <div class="wrap"><%----%>
        <div class="state-picker-head" data-reveal><%----%>
            <c:if test="${value.Eyebrow.isSet}"><span class="eyebrow"><span class="dot"></span>${value.Eyebrow}</span></c:if><%----%>
            <h2 ${ade ? content.rdfa.Title : ''}>${value.Title}</h2><%----%>
        </div><%----%>

        <div class="state-picker-grid" data-reveal-stagger><%----%>
            <c:forEach var="tile" items="${content.valueList.Tile}"><%----%>
                <c:set var="status"  value="${tile.value.Status.isSet ? tile.value.Status : 'live'}" /><%----%>
                <c:set var="hasLink" value="${tile.value.Link.exists and tile.value.Link.value.URI.isSet}" /><%----%>
                <c:choose>
                    <c:when test="${hasLink and status eq 'live'}">
                        <m:link link="${tile.value.Link}" css="state-pick state-pick--live"><%----%>
                            <span>${tile.value.Name}</span><%----%>
                            <c:choose><c:when test="${tile.value.Note.isSet}"><span class="state-pick-note">${tile.value.Note}</span></c:when><c:otherwise>${arrowSvg}</c:otherwise></c:choose><%----%>
                        </m:link><%----%>
                    </c:when>
                    <c:otherwise>
                        <span class="state-pick state-pick--${status eq 'live' ? 'live' : 'pending'}"><%----%>
                            <span>${tile.value.Name}</span><%----%>
                            <c:if test="${tile.value.Note.isSet}"><span class="state-pick-note">${tile.value.Note}</span></c:if><%----%>
                        </span><%----%>
                    </c:otherwise>
                </c:choose>
            </c:forEach><%----%>
        </div><%----%>
    </div><%----%>
</section><%----%>

</m:setting-defaults>
</cms:formatter>
</m:init-messages>
